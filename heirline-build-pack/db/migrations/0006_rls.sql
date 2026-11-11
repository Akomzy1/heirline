-- Heirline 0006: row-level security. TRD §7.1–7.3, §14.1.
-- Model: ALL mutations go through server actions using the service role after an authorisation check in code.
-- RLS therefore protects READS and any direct client access. Authenticated users get SELECT only, and only through these policies.
-- Default deny: RLS is enabled and FORCED on every table; a table with no policy is unreadable. Every policy needs a test in db/tests/rls.sql.

-- ---------- helper functions (SECURITY DEFINER, empty search_path) ----------
create or replace function ops.my_role() returns text
language sql stable security definer set search_path = '' as $$
  select s.role::text from ops.staff s where s.user_id = auth.uid() and s.active and s.mfa_enrolled
$$;

create or replace function ops.has_jit(fam uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select ops.my_role() = 'verifier' and exists (
    select 1 from ops.jit_sessions j
    join ops.engagements e on e.id = j.engagement_id
    where j.verifier_id = auth.uid() and j.family_id = fam
      and e.verifier_id = auth.uid()
      and j.closed_at is null and now() < j.expires_at)
$$;

create or replace function ops.can_read_engagement(eng uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select case ops.my_role()
    when 'admin'    then true      -- engagement metadata only; no client data policies grant admin access
    when 'dpo'      then true
    when 'analyst'  then exists (select 1 from ops.engagements e where e.id = eng and auth.uid() = any(e.assigned_analysts))
    when 'verifier' then exists (select 1 from ops.engagements e where e.id = eng and e.verifier_id = auth.uid())
    else false end
$$;

create or replace function ops.has_task_on_family(fam uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select ops.my_role() = 'analyst' and exists (
    select 1 from ops.tasks t join ops.engagements e on e.id = t.engagement_id
    where t.assignee = auth.uid() and t.status in ('open','in_progress') and e.family_id = fam)
$$;

create or replace function ops.can_read_identity(fam uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select ops.has_jit(fam) or (ops.my_role() = 'analyst' and exists (
    select 1 from ops.tasks t join ops.engagements e on e.id = t.engagement_id
    where t.assignee = auth.uid() and t.status in ('open','in_progress') and e.family_id = fam and t.scope_identity))
$$;

create or replace function ops.can_read_asset(aid uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from register.assets a
    where a.id = aid and (
      ops.has_jit(a.family_id)
      or (ops.my_role() = 'analyst' and exists (
            select 1 from ops.tasks t join ops.engagements e on e.id = t.engagement_id
            where t.assignee = auth.uid() and t.status in ('open','in_progress') and e.family_id = a.family_id
              and (a.type = any(t.scope_asset_types) or a.id = any(t.scope_asset_ids))))))
$$;

create or replace function ops.can_read_document(did uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from evidence.documents d
    where d.id = did and (
      ops.has_jit(d.family_id)
      or (ops.my_role() = 'analyst' and exists (
            select 1 from ops.tasks t join ops.engagements e on e.id = t.engagement_id
            where t.assignee = auth.uid() and t.status in ('open','in_progress') and e.family_id = d.family_id
              and d.id = any(t.scope_document_ids)))))
$$;

-- ---------- enable + force RLS everywhere, strip default grants ----------
do $$
declare r record;
begin
  for r in select schemaname, tablename from pg_tables
           where schemaname in ('crypto','identity','register','evidence','ops','config','audit','leads') loop
    execute format('alter table %I.%I enable row level security', r.schemaname, r.tablename);
    execute format('alter table %I.%I force row level security', r.schemaname, r.tablename);
    execute format('revoke all on %I.%I from anon, authenticated', r.schemaname, r.tablename);
  end loop;
end $$;

do $$
declare s text;
begin
  foreach s in array array['crypto','identity','register','evidence','ops','config','audit','leads'] loop
    execute format('grant usage on schema %I to authenticated', s);
  end loop;
end $$;

-- ---------- policies (SELECT only) ----------
-- identity
grant select on identity.families, identity.persons, identity.identity_variants to authenticated;
create policy families_read on identity.families for select to authenticated using (
  ops.my_role() in ('admin','dpo') or exists (select 1 from ops.engagements e where e.family_id = identity.families.id and ops.can_read_engagement(e.id)));
create policy persons_read on identity.persons for select to authenticated using (ops.can_read_identity(family_id));
create policy variants_read on identity.identity_variants for select to authenticated using (
  exists (select 1 from identity.persons p where p.id = person_id and ops.can_read_identity(p.family_id)));

-- register
grant select on register.assets, register.parcels, register.holdings, register.findings, register.parcel_score_runs, register.asset_evidence to authenticated;
create policy assets_read   on register.assets   for select to authenticated using (ops.can_read_asset(id));
create policy parcels_read  on register.parcels  for select to authenticated using (ops.can_read_asset(asset_id));
create policy holdings_read on register.holdings for select to authenticated using (ops.can_read_asset(asset_id));
create policy score_runs_read on register.parcel_score_runs for select to authenticated using (ops.can_read_asset(asset_id));
create policy asset_evidence_read on register.asset_evidence for select to authenticated using (ops.can_read_asset(asset_id));
create policy findings_read on register.findings for select to authenticated using (ops.has_jit(family_id) or ops.has_task_on_family(family_id));

-- evidence
grant select on evidence.documents, evidence.extractions, evidence.examinations, evidence.evidence_items, evidence.source_rows to authenticated;
create policy documents_read on evidence.documents for select to authenticated using (ops.can_read_document(id));
create policy extractions_read on evidence.extractions for select to authenticated using (ops.can_read_document(document_id));
create policy examinations_read on evidence.examinations for select to authenticated using (
  exists (select 1 from evidence.extractions x where x.id = extraction_id and ops.can_read_document(x.document_id)));
create policy evidence_items_read on evidence.evidence_items for select to authenticated using (ops.can_read_document(document_id));
create policy source_rows_read on evidence.source_rows for select to authenticated using (ops.can_read_document(document_id));

-- ops
grant select on ops.staff, ops.partners, ops.engagements, ops.consents, ops.letters_of_authority, ops.tasks, ops.recovery_cases,
  ops.match_candidates, ops.perfection_plans, ops.perfection_plan_items, ops.reports, ops.partner_packets, ops.report_links,
  ops.payments, ops.verifications, ops.verification_items, ops.jit_sessions to authenticated;
create policy staff_read on ops.staff for select to authenticated using (user_id = auth.uid() or ops.my_role() = 'admin');
create policy partners_read on ops.partners for select to authenticated using (ops.my_role() is not null);
create policy engagements_read on ops.engagements for select to authenticated using (ops.can_read_engagement(id));
create policy consents_read on ops.consents for select to authenticated using (ops.can_read_engagement(engagement_id));
create policy loa_read on ops.letters_of_authority for select to authenticated using (ops.can_read_engagement(engagement_id) and ops.my_role() <> 'admin');
create policy tasks_read on ops.tasks for select to authenticated using (assignee = auth.uid() or ops.my_role() = 'admin');
create policy recovery_read on ops.recovery_cases for select to authenticated using (ops.can_read_engagement(engagement_id) and ops.my_role() in ('analyst','verifier'));
create policy match_read on ops.match_candidates for select to authenticated using (ops.can_read_engagement(engagement_id) and ops.my_role() = 'analyst');
create policy plans_read on ops.perfection_plans for select to authenticated using (ops.can_read_engagement(engagement_id) and ops.my_role() in ('analyst','verifier'));
create policy plan_items_read on ops.perfection_plan_items for select to authenticated using (
  exists (select 1 from ops.perfection_plans p where p.id = plan_id and ops.can_read_engagement(p.engagement_id) and ops.my_role() in ('analyst','verifier')));
create policy reports_read on ops.reports for select to authenticated using (ops.can_read_engagement(engagement_id) and ops.my_role() in ('analyst','verifier'));
create policy packets_read on ops.partner_packets for select to authenticated using (ops.can_read_engagement(engagement_id) and ops.my_role() in ('analyst','verifier'));
create policy links_read on ops.report_links for select to authenticated using (
  exists (select 1 from ops.reports r where r.id = report_id and ops.can_read_engagement(r.engagement_id) and ops.my_role() in ('analyst','verifier')));
create policy payments_read on ops.payments for select to authenticated using (ops.can_read_engagement(engagement_id) and ops.my_role() in ('admin','analyst'));
create policy verifications_read on ops.verifications for select to authenticated using (ops.can_read_engagement(engagement_id) and ops.my_role() in ('analyst','verifier'));
create policy ver_items_read on ops.verification_items for select to authenticated using (
  exists (select 1 from ops.verifications v where v.id = verification_id and ops.can_read_engagement(v.engagement_id) and ops.my_role() in ('analyst','verifier')));
create policy jit_read on ops.jit_sessions for select to authenticated using (verifier_id = auth.uid() or ops.my_role() in ('admin','dpo'));

-- config: every active staff member reads; writes are service role only (admin proposes, a second person approves)
grant select on config.config_versions to authenticated;
create policy config_read on config.config_versions for select to authenticated using (ops.my_role() is not null);

-- audit: admin and DPO read-only
grant select on audit.events, audit.ai_calls to authenticated;
create policy audit_read on audit.events for select to authenticated using (ops.my_role() in ('admin','dpo'));
create policy ai_calls_read on audit.ai_calls for select to authenticated using (ops.my_role() = 'admin');

-- crypto.family_keys and leads.consultation_requests: NO policies on purpose (service role only).

-- ---------- coverage guard (call from CI: must return zero rows) ----------
create or replace function public.rls_coverage_gaps() returns table(schemaname text, tablename text)
language sql stable as $$
  select t.schemaname::text, t.tablename::text from pg_tables t
  where t.schemaname in ('crypto','identity','register','evidence','ops','config','audit','leads')
    and not (select c.relrowsecurity and c.relforcerowsecurity from pg_class c
             join pg_namespace n on n.oid = c.relnamespace where n.nspname = t.schemaname and c.relname = t.tablename)
$$;
