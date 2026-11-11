-- Heirline 0005: verification + JIT access, config packs, audit chain. TRD §5.2, §7.3, §10.1, §14.

-- ===================== config (T7: config is law) =====================
create table config.config_versions (
  id uuid primary key default gen_random_uuid(),
  pack text not null check (pack in ('title_rules','fee_schedule','match_thresholds','source_registry')),
  jurisdiction text not null,                            -- e.g. NG-LA
  version text not null,                                 -- e.g. 2026.11.0
  content_yaml text not null,
  sha256 bytea not null,
  effective_from date not null,
  created_by uuid not null,
  approved_by uuid,
  approved_at timestamptz,
  created_at timestamptz not null default now(),
  unique (pack, jurisdiction, version),
  constraint sha_matches_content check (sha256 = extensions.digest(convert_to(content_yaml,'UTF8'),'sha256')),
  constraint reviewer_differs check (approved_by is null or approved_by <> created_by)   -- four-eyes
);

-- Approved packs are immutable. A change is a new version.
create or replace function config.guard_immutable() returns trigger language plpgsql as $$
begin
  if tg_op = 'DELETE' and old.approved_at is not null then raise exception 'approved config version % is immutable', old.id; end if;
  if tg_op = 'UPDATE' and old.approved_at is not null then raise exception 'approved config version % is immutable; publish a new version', old.id; end if;
  return coalesce(new, old);
end $$;
create trigger config_versions_immutable before update or delete on config.config_versions
  for each row execute function config.guard_immutable();

alter table register.parcel_score_runs
  add constraint score_run_config_fk foreign key (config_version_id) references config.config_versions(id);

-- ===================== verification (VER-1..4) =====================
create table ops.verifications (
  id uuid primary key default gen_random_uuid(),
  engagement_id uuid not null unique references ops.engagements(id),
  preparer_id uuid not null,
  verifier_id uuid not null,
  checklist_json jsonb,                                  -- snapshot taken at signing
  statement_template_version text not null,
  signed_at timestamptz,
  signature_ref text,
  signer_ican_ref text,                                  -- masked reference only
  report_id uuid references ops.reports(id),
  created_at timestamptz not null default now(),
  constraint preparer_is_not_signer check (preparer_id <> verifier_id)      -- VER-1, enforced in the database
);

create table ops.verification_items (
  id uuid primary key default gen_random_uuid(),
  verification_id uuid not null references ops.verifications(id),
  asset_class text not null,
  label text not null,
  done_at timestamptz,
  done_by uuid
);
create index on ops.verification_items (verification_id);

create or replace function ops.guard_sign() returns trigger language plpgsql as $$
declare eng_verifier uuid; open_items int;
begin
  if new.signed_at is not null and old.signed_at is null then
    select verifier_id into eng_verifier from ops.engagements where id = new.engagement_id;
    if eng_verifier is distinct from new.verifier_id then
      raise exception 'signer must be the verifier assigned to the engagement';
    end if;
    select count(*) into open_items from ops.verification_items where verification_id = new.id and done_at is null;
    if open_items > 0 then raise exception 'checklist incomplete: % open item(s)', open_items; end if;   -- VER-2
    if not exists (select 1 from ops.verification_items where verification_id = new.id) then
      raise exception 'checklist is empty';
    end if;
    if new.signature_ref is null then raise exception 'signature reference required'; end if;
  end if;
  if old.signed_at is not null then raise exception 'a signed verification is immutable'; end if;
  return new;
end $$;
create trigger verifications_sign_guard before update on ops.verifications
  for each row execute function ops.guard_sign();

-- Just-in-time, time-boxed, logged full-register access (TRD §7.3). No standing access exists.
create table ops.jit_sessions (
  id uuid primary key default gen_random_uuid(),
  verifier_id uuid not null,
  engagement_id uuid not null references ops.engagements(id),
  family_id uuid not null references identity.families(id),
  reason text not null check (length(btrim(reason)) >= 10),
  opened_at timestamptz not null default now(),
  expires_at timestamptz not null,
  renewed_at timestamptz,
  closed_at timestamptz,
  constraint jit_default_4h check (expires_at <= opened_at + interval '4 hours' + interval '1 minute' or renewed_at is not null),
  constraint jit_max_8h check (expires_at <= opened_at + interval '8 hours' + interval '1 minute')   -- one renewal only
);
create index on ops.jit_sessions (verifier_id, family_id);

-- ===================== audit (append-only, hash-chained) =====================
create table audit.events (
  seq bigint generated always as identity primary key,
  id uuid not null default gen_random_uuid() unique,
  ts timestamptz not null default now(),
  actor_id uuid,
  actor_role text,
  action text not null,                                  -- e.g. field.revealed, jit.opened, statement.signed
  object_type text,
  object_id uuid,
  family_id uuid,
  reason text,
  ip_hash bytea,
  prev_hash bytea,
  hash bytea not null
);
create index on audit.events (family_id, ts desc);
create index on audit.events (actor_id, ts desc);

create or replace function audit.chain() returns trigger language plpgsql as $$
declare last_hash bytea;
begin
  perform pg_advisory_xact_lock(hashtext('audit.events.chain'));         -- serialise appends
  select hash into last_hash from audit.events order by seq desc limit 1;
  new.prev_hash := last_hash;
  new.ts := coalesce(new.ts, now());
  new.hash := extensions.digest(
    convert_to(
      coalesce(encode(last_hash,'hex'),'GENESIS') || '|' || new.ts::text || '|' || coalesce(new.actor_id::text,'') || '|' ||
      coalesce(new.actor_role,'') || '|' || new.action || '|' || coalesce(new.object_type,'') || '|' ||
      coalesce(new.object_id::text,'') || '|' || coalesce(new.family_id::text,'') || '|' || coalesce(new.reason,''),
      'UTF8'),
    'sha256');
  return new;
end $$;
create trigger audit_chain before insert on audit.events for each row execute function audit.chain();

create or replace function audit.block_mutation() returns trigger language plpgsql as $$
begin raise exception 'audit.events is append-only'; end $$;
create trigger audit_no_update before update or delete on audit.events for each row execute function audit.block_mutation();
create trigger audit_no_truncate before truncate on audit.events for each statement execute function audit.block_mutation();

-- Weekly integrity job calls this. Returns ok=false and the first broken seq if the chain was tampered with.
create or replace function audit.verify_chain() returns table(ok boolean, broken_at bigint) language plpgsql as $$
declare r record; prev bytea := null; expect bytea;
begin
  for r in select * from audit.events order by seq loop
    expect := extensions.digest(
      convert_to(
        coalesce(encode(prev,'hex'),'GENESIS') || '|' || r.ts::text || '|' || coalesce(r.actor_id::text,'') || '|' ||
        coalesce(r.actor_role,'') || '|' || r.action || '|' || coalesce(r.object_type,'') || '|' ||
        coalesce(r.object_id::text,'') || '|' || coalesce(r.family_id::text,'') || '|' || coalesce(r.reason,''),
        'UTF8'),
      'sha256');
    if r.prev_hash is distinct from prev or r.hash <> expect then
      return query select false, r.seq; return;
    end if;
    prev := r.hash;
  end loop;
  return query select true, null::bigint;
end $$;

-- AI call log (TRD §9.1 step 4). No prompt or response bodies.
create table audit.ai_calls (
  id uuid primary key default gen_random_uuid(),
  ts timestamptz not null default now(),
  task text not null,                                    -- classify | extract | examine | match_rationale | title_analyst | plan_narrative
  model text not null,
  prompt_version text not null,
  schema_version text not null,
  input_tokens int,
  output_tokens int,
  latency_ms int,
  outcome text not null check (outcome in ('ok','schema_invalid_retried','schema_invalid_human_queue','error')),
  document_id uuid,
  family_id uuid
);
