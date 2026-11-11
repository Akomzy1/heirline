-- Heirline 0100: V1 tables (vault, monitor, heir access, will health check). DO NOT APPLY IN THE MVP.
-- Apply only when Track C starts. Source: TRD §5.3, §8.3–8.4; PRD §7.9–7.13a.
-- Prerequisites: independent cryptography review commissioned (TRD §8.3 [VERIFY]); PostGIS enabled.

create extension if not exists postgis with schema extensions;
create schema if not exists vault;
create schema if not exists monitor;

create type vault.holder_type  as enum ('principal','lawyer','heirline');       -- UI label: "key holders". Never "custodian".
create type vault.trigger_type as enum ('death','incapacity');
create type vault.trigger_state as enum ('SEALED','TRIGGER_REPORTED','ATTESTATIONS_PENDING','COOLING_OFF','HALTED','RELEASE_APPROVED','RELEASED');
create type vault.access_level as enum ('L0','L1','L2','L3');                    -- none / plan exists + who to call / categories / full register
create type vault.release_scope as enum ('executor_pack','full','category_list','contacts_only');

create table vault.vaults (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references identity.families(id),
  version int not null,
  sealed_blob_ref text not null,                          -- ciphertext only; encrypted in the principal's browser
  blob_sha256 bytea not null,
  dek_wrap_scheme text not null,
  created_at timestamptz not null default now(),
  unique (family_id, version)
);
create table vault.key_shares (
  id uuid primary key default gen_random_uuid(),
  vault_id uuid not null references vault.vaults(id),
  holder_type vault.holder_type not null,
  holder_id uuid,
  share_ref text not null,
  wrapped_with text not null,
  unique (vault_id, holder_type)                          -- exactly one share per key holder
);
create table vault.release_maps (
  id uuid primary key default gen_random_uuid(),
  vault_id uuid not null references vault.vaults(id),
  recipient_person_id uuid not null references identity.persons(id),
  scope vault.release_scope not null
);
create table vault.trigger_events (
  id uuid primary key default gen_random_uuid(),
  vault_id uuid not null references vault.vaults(id),
  type vault.trigger_type not null,
  state vault.trigger_state not null default 'TRIGGER_REPORTED',
  attestations_json public.enc_blob,
  cooling_off_ends_at timestamptz,
  decided_by uuid,
  outcome text,
  created_at timestamptz not null default now(),
  -- fail closed: RELEASE_APPROVED/RELEASED need the cooling-off to have ended and a human decision recorded
  constraint release_needs_cooling_off check (state not in ('RELEASE_APPROVED','RELEASED') or (cooling_off_ends_at is not null and decided_by is not null))
);
create table vault.access_grants (
  id uuid primary key default gen_random_uuid(),
  person_id uuid not null references identity.persons(id),
  level vault.access_level not null default 'L0',
  scope jsonb not null default '{}',
  expires_at timestamptz
);

-- Pseudonymised: no family_id, no names. The link pseudo_id -> asset_id lives in register only.
create table monitor.parcels (
  pseudo_id uuid primary key default gen_random_uuid(),
  geometry extensions.geography(Polygon, 4326) not null,
  baseline_image_ref text,
  last_checked_at timestamptz
);
create index on monitor.parcels using gist (geometry);
create table register.parcel_pseudonyms (
  asset_id uuid primary key references register.assets(id),
  pseudo_id uuid not null unique references monitor.parcels(pseudo_id)
);
create table monitor.detections (
  id uuid primary key default gen_random_uuid(),
  pseudo_id uuid not null references monitor.parcels(pseudo_id),
  source text not null,
  change_score numeric not null,
  image_refs jsonb,
  triage_status text not null default 'new' check (triage_status in ('new','false_positive','field_check','confirmed')),
  field_check_id uuid,
  created_at timestamptz not null default now()
);
create table monitor.reg_sources (id uuid primary key default gen_random_uuid(), name text not null, url text not null, active boolean not null default true);
create table monitor.reg_changes (
  id uuid primary key default gen_random_uuid(),
  source_id uuid not null references monitor.reg_sources(id),
  fetched_at timestamptz not null default now(),
  diff_ref text, summary text, tags text[] default '{}',
  approved_by uuid                                         -- an analyst approves before any client alert
);

-- Will health check (WILL-1..6). Stores the CHECKLIST OUTCOME and the law firm's attestation, never the will's contents.
create table ops.will_checks (
  id uuid primary key default gen_random_uuid(),
  engagement_id uuid not null references ops.engagements(id),
  partner_id uuid not null references ops.partners(id),
  due_at date not null,
  checked_at timestamptz,
  will_exists boolean,
  will_date date,
  execution_witnessing_confirmed boolean,
  original_location text check (original_location in ('probate_registry','trustee_custody','other')),
  executors_confirmed boolean,
  codicils_exist boolean,
  gaps_json public.enc_blob,                              -- 🔒 asset ids not covered / no longer in register (reconciliation, WILL-4)
  attestation_doc_id uuid references evidence.documents(id),
  created_at timestamptz not null default now()
);

do $$ declare r record; begin
  for r in select schemaname, tablename from pg_tables where schemaname in ('vault','monitor') or tablename in ('will_checks','parcel_pseudonyms') loop
    execute format('alter table %I.%I enable row level security', r.schemaname, r.tablename);
    execute format('alter table %I.%I force row level security', r.schemaname, r.tablename);
  end loop; end $$;
-- Policies for V1 tables are written in Track C with their tests. Until then: default deny, service role only.
