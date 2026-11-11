-- Heirline 0002: identity + wrapped keys. TRD §5.2, §8.
-- identity is the ONLY schema holding client names. Staff UIs show families.code_name.

-- Wrapped data keys: DEK per family per data class, wrapped by the family KEK held in KMS.
create table crypto.family_keys (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null,
  data_class text not null check (data_class in ('identity','register','evidence')),   -- website leads use a platform key, not a family key
  wrapped_dek bytea not null,
  kek_ref text not null,                 -- KMS key id/arn; destroying it crypto-shreds the family
  version int not null default 1,
  created_at timestamptz not null default now(),
  destroyed_at timestamptz,
  unique (family_id, data_class, version)
);

create table identity.families (
  id uuid primary key default gen_random_uuid(),
  code_name text not null unique check (code_name = upper(code_name)),  -- random label, e.g. KESTREL
  status text not null default 'active' check (status in ('active','offboarded')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
select public.attach_updated_at('identity.families');

alter table crypto.family_keys add constraint family_keys_family_fk foreign key (family_id) references identity.families(id);

create table identity.persons (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references identity.families(id),
  role identity.person_role not null,
  display_name public.enc_blob not null,                 -- 🔒
  dob public.enc_blob,                                   -- 🔒
  contacts public.enc_blob,                              -- 🔒
  kyc_status identity.kyc_status not null default 'not_started',
  kyc_ref_hash bytea,                                    -- salted hash only; NEVER the raw NIN
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index on identity.persons (family_id);
select public.attach_updated_at('identity.persons');

create table identity.identity_variants (
  id uuid primary key default gen_random_uuid(),
  person_id uuid not null references identity.persons(id),
  variant_type identity.variant_type not null,
  value public.enc_blob not null,                        -- 🔒
  normalised_value_hash bytea not null,                  -- keyed HMAC for equality lookup
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index on identity.identity_variants (person_id);
create index on identity.identity_variants (normalised_value_hash);
select public.attach_updated_at('identity.identity_variants');
