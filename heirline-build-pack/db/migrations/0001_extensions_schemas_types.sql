-- Heirline 0001: schemas, shared types, helpers.
-- Source: TRD §5.1. PostGIS is NOT needed in the MVP (geometry is stored encrypted; see 0100 for V1 monitor).
-- Conventions: every table has id uuid pk, created_at, updated_at, created_by.
-- "enc_blob" columns are application-layer ciphertext: {v, iv, ct, tag, key_ref}. Never plaintext.

-- On Supabase, extensions live in the 'extensions' schema. Locally we create it so the same SQL runs.
create schema if not exists extensions;
create extension if not exists pgcrypto with schema extensions;

create schema if not exists crypto;     -- wrapped data keys (service role only)
create schema if not exists identity;   -- people, identity variants (the ONLY place client names live)
create schema if not exists register;   -- assets, parcels, holdings, findings, scores
create schema if not exists evidence;   -- documents, extractions, examinations, evidence items
create schema if not exists ops;        -- engagements, tasks, consents, payments, recovery, verification, reports
create schema if not exists config;     -- versioned rule packs, fee schedules, thresholds, source registries
create schema if not exists audit;      -- append-only hash-chained log, AI call log
create schema if not exists leads;      -- pre-engagement website enquiries (encrypted)

-- Application-layer ciphertext container.
create domain public.enc_blob as jsonb
  check (value ? 'v' and value ? 'iv' and value ? 'ct' and value ? 'tag' and value ? 'key_ref');

-- ---------- enums ----------
create type ops.staff_role        as enum ('admin','analyst','verifier','dpo');
create type ops.product           as enum ('health_check','trace','retainer','heir');
create type ops.engagement_stage  as enum ('onboarding','intake','discovery','title_review','verification','delivered');
create type ops.engagement_status as enum ('active','paused','closed');
create type ops.consent_category  as enum ('identity','land_title','shares_dividends','bank_accounts','pensions_policies','private_stakes','offshore','third_party_searches','ai_document_processing');
create type ops.task_status       as enum ('open','in_progress','blocked','done','cancelled');
create type ops.recovery_type     as enum ('dividend','dormant','mandate','title');
create type ops.recovery_status   as enum ('identified','letter_sent','awaiting_response','claim_filed','recovered','closed');
create type ops.owner_party       as enum ('heirline','law_firm','registrar','bank');
create type ops.partner_type      as enum ('law_firm','trustee','surveyor','vetting','bank');
create type ops.payment_status    as enum ('pending','succeeded','failed','refunded');
create type ops.match_status      as enum ('queued','confirmed','rejected','needs_evidence');
create type ops.report_kind       as enum ('client_report','law_firm_packet','trustee_schedule');

create type identity.person_role  as enum ('principal','spouse','heir','executor','other');
create type identity.variant_type as enum ('alias','maiden','initials','historic_address','old_employer');
create type identity.kyc_status   as enum ('not_started','pending','verified','failed');

create type register.asset_type   as enum ('land_parcel','listed_shares','unclaimed_dividend','bank_account','pension_rsa','policy','private_stake','receivable','offshore','vehicle','other');
create type register.verification_status as enum ('claimed','evidenced','verified','disputed');
create type register.holding_type as enum ('shares','account','rsa','policy','private_stake','receivable','offshore');
create type register.finding_type as enum ('gap','risk','recoverable','exposure');
create type register.evidence_relation as enum ('supports','contradicts');
create type register.risk_band    as enum ('low','moderate','high','critical','unscored');

create type evidence.doc_class    as enum ('c_of_o','deed_of_assignment','governors_consent','survey_plan','receipt','family_conveyance','share_certificate','dividend_warrant','bank_statement','rsa_statement','policy','dormant_list','registrar_letter','other','unreadable');
create type evidence.doc_source   as enum ('client','registry','registrar','bank','surveyor');
create type evidence.exam_result  as enum ('pass','mismatch','unreadable');

-- ---------- helpers ----------
create or replace function public.set_updated_at() returns trigger
language plpgsql as $$ begin new.updated_at := now(); return new; end $$;

-- Attach the updated_at trigger to a table: select public.attach_updated_at('ops.tasks');
create or replace function public.attach_updated_at(tbl regclass) returns void
language plpgsql as $$
begin
  execute format('create trigger set_updated_at before update on %s for each row execute function public.set_updated_at()', tbl);
end $$;
