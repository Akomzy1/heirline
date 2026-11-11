-- Heirline 0003: evidence + register. TRD §5.2.
-- 🔒 = application-layer encrypted (public.enc_blob). Geometry is stored encrypted; PostGIS ops run in memory in the job runner (MVP).

-- ===================== evidence =====================
create table evidence.documents (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references identity.families(id),
  doc_class evidence.doc_class,                          -- null until classified
  classification_confidence numeric(4,3),
  storage_path text not null,                            -- ciphertext object in a private bucket
  file_key_ref text not null,                            -- which DEK version encrypted the file
  sha256 bytea not null,                                 -- of the plaintext, for integrity
  page_count int,
  status text not null default 'uploaded'
    check (status in ('uploaded','classified','extracting','needs_review','unreadable','resolved')),
  source evidence.doc_source not null default 'client',
  uploaded_by uuid,
  retention_until date,                                  -- default: 90 days after report delivery (TRD §5.4)
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index on evidence.documents (family_id);
select public.attach_updated_at('evidence.documents');

create table evidence.extractions (
  id uuid primary key default gen_random_uuid(),
  document_id uuid not null references evidence.documents(id),
  model text not null,
  prompt_version text not null,
  schema_version text not null,
  fields_json public.enc_blob not null,                  -- 🔒
  confidence_json jsonb not null,                        -- per-field confidence (no values)
  created_at timestamptz not null default now()
);
create index on evidence.extractions (document_id);

create table evidence.examinations (
  id uuid primary key default gen_random_uuid(),
  extraction_id uuid not null references evidence.extractions(id),
  model text not null,
  prompt_version text not null,
  schema_version text not null,
  result evidence.exam_result not null,
  field_results jsonb not null,                          -- {field: match|mismatch|not_found} (no values)
  mismatches_json public.enc_blob,                       -- 🔒 notes may quote values
  created_at timestamptz not null default now()
);
create index on evidence.examinations (extraction_id);

create table evidence.evidence_items (
  id uuid primary key default gen_random_uuid(),
  document_id uuid not null references evidence.documents(id),
  page int not null,
  field_name text not null,
  value public.enc_blob not null,                        -- 🔒
  extraction_id uuid references evidence.extractions(id),
  examination_id uuid references evidence.examinations(id),
  resolved_by uuid,                                      -- set when an analyst resolved it
  resolution text check (resolution in ('examiner_match','analyst_accepted','analyst_edited')),
  created_at timestamptz not null default now(),
  -- Fail closed: a field is only evidence if the examiner matched it or a human resolved it.
  constraint evidence_needs_basis check (
    (examination_id is not null and resolution = 'examiner_match')
    or (resolved_by is not null and resolution in ('analyst_accepted','analyst_edited'))
  )
);
create index on evidence.evidence_items (document_id);

-- Rows parsed from uploaded source lists (dormant-account lists, registrar responses).
create table evidence.source_rows (
  id uuid primary key default gen_random_uuid(),
  document_id uuid not null references evidence.documents(id),
  row_no int not null,
  row_json public.enc_blob not null,                     -- 🔒
  row_hash bytea not null,
  created_at timestamptz not null default now(),
  unique (document_id, row_no)
);

-- ===================== register =====================
create table register.assets (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references identity.families(id),
  type register.asset_type not null,
  description public.enc_blob,                           -- 🔒
  owner_of_record_person_id uuid references identity.persons(id),
  value_band text,                                       -- weights live in config
  verification_status register.verification_status not null default 'claimed',
  status_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index on register.assets (family_id, type);
select public.attach_updated_at('register.assets');

create table register.parcels (
  asset_id uuid primary key references register.assets(id),
  state text not null default 'Lagos',
  lga text,
  locality text,
  geometry_enc public.enc_blob,                          -- 🔒 encrypted GeoJSON polygon
  title_doc_type text check (title_doc_type in ('registered_c_of_o_or_consent','unregistered_deed','survey_plan_only','receipt_or_family_conveyance_only')),
  title_ref public.enc_blob,                             -- 🔒
  charting_result text check (charting_result in ('free','committed','under_acquisition')),
  gazette_status text,
  encumbrances_json public.enc_blob,                     -- 🔒
  occupation_status text check (occupation_status in ('owner','third_party','unknown')),
  risk_score int,
  risk_band register.risk_band not null default 'unscored',
  rule_version text,
  config_sha256 bytea,
  scored_at timestamptz
);

-- Every scoring run is kept so a config change produces a re-score diff, never a silent change.
create table register.parcel_score_runs (
  id uuid primary key default gen_random_uuid(),
  asset_id uuid not null references register.assets(id),
  config_version_id uuid not null,                       -- fk added in 0005 (config schema)
  rule_version text not null,
  config_sha256 bytea not null,
  input_json public.enc_blob not null,                   -- 🔒 the ParcelEvidence object
  score int,
  band register.risk_band not null,
  hits jsonb not null default '[]',
  missing_evidence jsonb not null default '[]',
  fee_estimate jsonb,
  supersedes uuid references register.parcel_score_runs(id),
  created_at timestamptz not null default now(),
  created_by uuid
);
create index on register.parcel_score_runs (asset_id, created_at desc);

create table register.holdings (
  asset_id uuid primary key references register.assets(id),
  holding_type register.holding_type not null,
  institution text,
  reference public.enc_blob,                             -- 🔒
  quantity public.enc_blob,                              -- 🔒
  last_known_date date
);

create table register.findings (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references identity.families(id),
  type register.finding_type not null,
  severity text not null check (severity in ('info','low','medium','high')),
  summary public.enc_blob not null,                      -- 🔒
  asset_ids uuid[] not null default '{}',
  generated_by text not null default 'rule' check (generated_by in ('rule','analyst')),  -- findings are rule-generated; LLM only drafts prose
  created_at timestamptz not null default now(),
  created_by uuid
);
create index on register.findings (family_id);

create table register.asset_evidence (
  asset_id uuid not null references register.assets(id),
  evidence_item_id uuid not null references evidence.evidence_items(id),
  field_name text not null,
  relation register.evidence_relation not null default 'supports',
  primary key (asset_id, evidence_item_id, field_name)
);

-- Change log for REG-4 (who, what, when) is written to audit.events by the app on every register edit.
