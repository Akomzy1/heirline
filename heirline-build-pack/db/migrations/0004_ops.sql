-- Heirline 0004: ops (engagements, tasks, consents, recovery, matcher, plan, reports, payments). TRD §5.2.
-- Staff display names are staff data, not client data. Client names never appear here.

create table ops.staff (
  user_id uuid primary key references auth.users(id),
  role ops.staff_role not null,
  display_name text not null,
  ican_number_enc public.enc_blob,                       -- 🔒 verifier only (shown masked: "ICAN •••• 3318")
  mfa_enrolled boolean not null default false,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
select public.attach_updated_at('ops.staff');

create table ops.partners (
  id uuid primary key default gen_random_uuid(),
  type ops.partner_type not null,
  name text not null,
  contact public.enc_blob,
  agreement_ref text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
select public.attach_updated_at('ops.partners');

create table ops.engagements (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references identity.families(id),
  product ops.product not null,
  scope_json jsonb not null default '{}',
  fee numeric(14,2),
  currency text check (currency in ('NGN','USD')),
  stage ops.engagement_stage not null default 'onboarding',
  status ops.engagement_status not null default 'active',
  assigned_analysts uuid[] not null default '{}',
  verifier_id uuid,
  due_at date,
  delivered_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid,
  -- VER-1: the signer must not be one of the preparers.
  constraint verifier_not_a_preparer check (verifier_id is null or not (verifier_id = any(assigned_analysts)))
);
create index on ops.engagements (family_id);
select public.attach_updated_at('ops.engagements');

create table ops.consents (
  id uuid primary key default gen_random_uuid(),
  engagement_id uuid not null references ops.engagements(id),
  person_id uuid not null references identity.persons(id),
  category ops.consent_category not null,
  text_version text not null,
  granted_at timestamptz not null default now(),
  method text not null check (method in ('esign','otp_click','wet_ink_scan')),
  withdrawn_at timestamptz
);
create index on ops.consents (engagement_id, category);

create table ops.letters_of_authority (
  id uuid primary key default gen_random_uuid(),
  engagement_id uuid not null references ops.engagements(id),
  target_type text not null check (target_type in ('registrar','bank','land_registry','other')),
  target_name text not null,
  signed_doc_id uuid references evidence.documents(id),
  valid_until date,
  created_at timestamptz not null default now()
);

create table ops.tasks (
  id uuid primary key default gen_random_uuid(),
  engagement_id uuid not null references ops.engagements(id),
  type text not null,                                    -- e.g. extraction_review, match_review, log_registrar_response, collect_evidence, sign_off
  title text not null,
  -- Task-scoped access (TRD §7.2): what this task unlocks. Drives RLS.
  scope_asset_types register.asset_type[] not null default '{}',
  scope_asset_ids uuid[] not null default '{}',
  scope_identity boolean not null default false,         -- may read identity variants for this family
  scope_document_ids uuid[] not null default '{}',       -- documents this task may open (e.g. the extraction under review)
  assignee uuid,
  status ops.task_status not null default 'open',
  due_at date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index on ops.tasks (assignee, status);
create index on ops.tasks (engagement_id);
select public.attach_updated_at('ops.tasks');

create table ops.recovery_cases (
  id uuid primary key default gen_random_uuid(),
  engagement_id uuid not null references ops.engagements(id),
  asset_id uuid references register.assets(id),
  type ops.recovery_type not null,
  owner_party ops.owner_party not null default 'heirline',
  status ops.recovery_status not null default 'identified',
  value_band text,
  sla_due_at timestamptz,
  outcome_value public.enc_blob,                         -- 🔒
  outcome_evidence_id uuid references evidence.evidence_items(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid,
  -- REC: cannot be Recovered without an outcome value and evidence.
  constraint recovered_needs_outcome check (status <> 'recovered' or (outcome_value is not null and outcome_evidence_id is not null))
);
create index on ops.recovery_cases (engagement_id, status);
select public.attach_updated_at('ops.recovery_cases');

-- Matcher candidates (DIS-5). Nothing is ever auto-confirmed.
create table ops.match_candidates (
  id uuid primary key default gen_random_uuid(),
  engagement_id uuid not null references ops.engagements(id),
  source_row_id uuid not null references evidence.source_rows(id),
  identity_variant_id uuid not null references identity.identity_variants(id),
  score numeric(5,4) not null check (score between 0 and 1),
  signals jsonb not null default '{}',                   -- name tokens, address fragment, institution, era
  threshold_version text not null,                       -- config match_thresholds version used
  rationale text,                                        -- LLM prose only; never sets the score
  status ops.match_status not null default 'queued',
  decided_by uuid,
  decided_at timestamptz,
  recovery_case_id uuid references ops.recovery_cases(id),
  created_at timestamptz not null default now(),
  constraint decided_needs_human check (status = 'queued' or (decided_by is not null and decided_at is not null))
);
create index on ops.match_candidates (engagement_id, status);

create table ops.perfection_plans (
  id uuid primary key default gen_random_uuid(),
  engagement_id uuid not null unique references ops.engagements(id),
  narrative public.enc_blob,                             -- 🔒 drafted by the model, edited by the analyst
  approved_by uuid,
  approved_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
select public.attach_updated_at('ops.perfection_plans');

create table ops.perfection_plan_items (
  id uuid primary key default gen_random_uuid(),
  plan_id uuid not null references ops.perfection_plans(id),
  asset_id uuid not null references register.assets(id),
  rank int not null,
  priority_score numeric,                                -- risk_weight × value_band_weight ÷ cost_band_weight (config weights)
  cost_low numeric(14,2),
  cost_high numeric(14,2),
  currency text default 'NGN',
  recommended_action text,
  partner_id uuid references ops.partners(id),
  status text not null default 'proposed' check (status in ('proposed','with_law_firm','in_progress','done')),
  unique (plan_id, asset_id)
);

create table ops.reports (
  id uuid primary key default gen_random_uuid(),
  engagement_id uuid not null references ops.engagements(id),
  kind ops.report_kind not null,
  storage_path text not null,
  file_key_ref text not null,
  sha256 bytea not null,
  statement_template_version text,
  watermark_recipient public.enc_blob,                   -- 🔒
  generated_by uuid,
  issued_at timestamptz,
  created_at timestamptz not null default now()
);

create table ops.partner_packets (
  id uuid primary key default gen_random_uuid(),
  engagement_id uuid not null references ops.engagements(id),
  partner_id uuid not null references ops.partners(id),
  packet_type text not null check (packet_type in ('law_firm_parcel','trustee_schedule')),
  asset_ids uuid[] not null,                             -- only assets in scope
  report_id uuid references ops.reports(id),
  issued_at timestamptz
);

-- Expiring, single-recipient, logged links. No PDFs by email or WhatsApp, ever.
create table ops.report_links (
  id uuid primary key default gen_random_uuid(),
  report_id uuid not null references ops.reports(id),
  token_hash bytea not null unique,                      -- only the hash of the token is stored
  recipient public.enc_blob not null,                    -- 🔒
  expires_at timestamptz not null,
  download_count int not null default 0,
  revoked_at timestamptz,
  created_at timestamptz not null default now(),
  created_by uuid,
  constraint link_max_7_days check (expires_at <= created_at + interval '7 days' + interval '1 minute')
);

create table ops.payments (
  id uuid primary key default gen_random_uuid(),
  engagement_id uuid not null references ops.engagements(id),
  provider text not null check (provider in ('paystack','stripe')),
  provider_ref text not null,
  amount numeric(14,2) not null,
  currency text not null check (currency in ('NGN','USD')),
  status ops.payment_status not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (provider, provider_ref)                        -- idempotent webhook handling
);
select public.attach_updated_at('ops.payments');

-- Website enquiries (Track B). Pre-engagement, so kept apart from identity and encrypted.
create table leads.consultation_requests (
  id uuid primary key default gen_random_uuid(),
  who_you_are text not null check (who_you_are in ('principal','family_member','executor','adviser')),
  help_with text[] not null default '{}',
  contact_method text check (contact_method in ('phone','email','whatsapp')),
  preferred_time text,
  contact public.enc_blob not null,                      -- 🔒 name + contact details
  consent_text_version text not null,
  consent_at timestamptz not null,
  status text not null default 'new' check (status in ('new','contacted','closed')),
  retain_until date not null default (current_date + 365),
  created_at timestamptz not null default now()
);
