# Heirline — Technical Requirements Document v0.1

**Companion to:** Heirline PRD v0.1 (8 Nov 2026)

| | |
|---|---|
| **Product** | Heirline (Heirline Nigeria Limited, proposed) |
| **Version** | 0.1 (first full draft) |
| **Date** | 8 November 2026 |
| **Owner** | Tokunbo Akomolede |
| **Scope** | MVP (months 0–3) in full detail; V1 (months 3–9) at design level; V2 noted only |
| **Status** | Draft. Items marked **[DECIDE]** need a decision before build; items marked **[VERIFY]** need confirmation with a vendor or adviser. |

---

## 1. Purpose and scope

This TRD turns the PRD into a buildable system design. It covers:
- architecture and component boundaries;
- data model, data separation and encryption;
- access control, including how the "no full family map" principle is enforced;
- the AI pipeline (extraction, examination, matching) and its guardrails;
- the deterministic title-risk rules engine;
- the sealed vault and trigger-release design (V1);
- monitoring pipelines (V1);
- integrations, non-functional requirements, testing and the MVP build plan.

**MVP reality check:** the MVP is a concierge service. The software is internal tooling used by Heirline staff and the verifying professional. Clients see only a report and a secure download link. No client portal, vault or monitoring ships in the MVP.

---

## 2. Design principles (technical form)

| # | Principle | Technical consequence |
|---|---|---|
| T1 | Non-custodial | No payments to or from client assets; no storage of original documents beyond engagement working copies |
| T2 | Compartmentalise | Identity, assets, evidence, vault and monitoring data live in separate schemas, linked by internal IDs only |
| T3 | Least privilege by task | Access granted per engagement and per task, not per role alone; full-register views are just-in-time and time-boxed (§7.3) |
| T4 | Deterministic core | Title-risk scores, fee estimates and release triggers are computed by versioned rules, never by an LLM |
| T5 | Generator / examiner separation | Extraction and examination are separate model calls with separate prompts; the examiner never sees the extractor's reasoning |
| T6 | Fail closed | Any ambiguous match, failed check, missing attestation or crypto error blocks progress and creates a human task |
| T7 | Config is law | Rules, fee schedules, thresholds and source registries are versioned config; every output records the config version it used |
| T8 | Evidence-linked | Every register field links to an evidence item, page and extraction record |
| T9 | Nothing sensitive leaves through messaging or analytics | Notifications are content-free; analytics receive no personal or asset data |

**Refinement of PRD principle 3.** The PRD says no staff role sees the full map. The verifying professional must see the whole register to sign it. The TRD resolves this with **just-in-time, time-boxed, logged full-register access** for the verifier during the sign-off window only (§7.3). No role has standing full-map access.

---

## 3. Architecture overview

```
                    ┌────────────────────────────────────────────┐
  Staff (analyst,   │  Next.js app (Vercel)                       │
  verifier, admin)──▶  - Internal console (MVP)                   │
                    │  - Client/partner portals (V1)              │
  Client (V1) ──────▶  - Server actions / route handlers          │
                    └──────┬─────────────────────┬───────────────┘
                           │                     │
                 ┌─────────▼────────┐   ┌────────▼─────────────┐
                 │ Supabase Postgres │   │ Durable job runner    │
                 │ + RLS + PostGIS   │   │ (extraction, matching,│
                 │ schemas:          │   │  reports, monitoring) │
                 │  identity         │   └────────┬─────────────┘
                 │  register         │            │
                 │  evidence         │   ┌────────▼─────────────┐
                 │  ops              │   │ AI gateway service    │
                 │  vault (V1)       │   │ - redaction           │
                 │  monitor (V1)     │   │ - model routing       │
                 │  audit            │   │ - schema validation   │
                 └─────────┬────────┘   └────────┬─────────────┘
                           │                     │
                 ┌─────────▼────────┐   ┌────────▼─────────────┐
                 │ Encrypted object  │   │ Claude API (tiered)   │
                 │ storage (private) │   └──────────────────────┘
                 └─────────┬────────┘
                           │
                 ┌─────────▼────────┐   ┌──────────────────────┐
                 │ Cloud KMS (keys)  │   │ Rules engine (pure TS │
                 │ envelope encrypt. │   │ library, versioned    │
                 └──────────────────┘   │ YAML config)          │
                                         └──────────────────────┘
  External: Paystack, Stripe, Resend, identity verification provider,
            e-signature, imagery provider (V1), WhatsApp Business (V1)
```

### Components

| Component | Responsibility | Phase |
|---|---|---|
| **Web app** | Internal console; later client, partner and heir portals | MVP / V1 |
| **Postgres (Supabase)** | System of record; RLS; PostGIS for parcels | MVP |
| **Object storage** | Encrypted document working copies; generated reports | MVP |
| **KMS** | Key hierarchy and envelope encryption | MVP |
| **Job runner** | Long-running and retryable work (extraction, matching, PDF generation, watchers) | MVP |
| **AI gateway** | Single choke point for all model calls: redaction, routing, schema validation, logging | MVP |
| **Rules engine** | Deterministic title-risk scoring and fee estimation | MVP |
| **Matcher** | Deterministic candidate generation for name and identity matching | MVP |
| **Report service** | PDF generation, per-recipient watermarking, expiring links | MVP |
| **Vault service** | Client-side sealing, key shares, trigger state machine, release | V1 |
| **Monitoring service** | Parcel change detection and regulatory watch | V1 |
| **Notification service** | Content-free email and WhatsApp nudges | V1 |

**[DECIDE] Job runner:** Inngest or Trigger.dev. Both handle retries, schedules and long jobs on a Vercel-hosted app. Pick one and use it for every background workflow.

---

## 4. Technology stack

| Layer | Choice | Notes |
|---|---|---|
| Language | TypeScript end to end | Shared types between app, jobs and rules engine |
| Framework | Next.js (App Router) + shadcn/ui + Tailwind | Server actions for mutations; no client-side access to sensitive tables |
| Database | Supabase Postgres + RLS + PostGIS | **[VERIFY]** available hosting regions and the NDPA cross-border transfer basis |
| Storage | Supabase Storage (private buckets) with application-layer encryption | Files are encrypted before upload (§8.2) |
| Keys | Cloud KMS (e.g. AWS KMS) | Envelope encryption; per-family data keys |
| Auth | Supabase Auth + mandatory TOTP or passkey MFA for all staff | SSO later if the team grows |
| AI | Claude API: Haiku / Sonnet / Opus via the AI gateway | **[VERIFY]** zero-data-retention eligibility and terms with Anthropic before any client document is processed |
| PDF | HTML-to-PDF in the job runner (headless Chromium) | Templates versioned in repo |
| Payments | Paystack (NGN), Stripe (USD) | Webhooks into `ops.payments` |
| Email | Resend | Content-free templates only |
| E-signature | **[DECIDE]** provider or in-app OTP click-sign | Engagement letters, consents, letters of authority |
| Identity verification | **[DECIDE]** Nigerian KYC provider (NIN-based) | Store result and a salted hash, never the raw NIN |
| Analytics | PostHog (self-hosted preferred) | Event names and counts only; no PII |
| Errors | Sentry (or equivalent) with PII scrubbing | Request bodies never captured |
| Hosting | Vercel (app), Supabase (data), job runner cloud | All in one region where possible |

---

## 5. Data architecture

### 5.1 Schema separation

| Schema | Contents | Who can read |
|---|---|---|
| `identity` | People, identity variants (aliases, maiden names, historic addresses), contact details, KYC results | Analysts on assigned engagements (identity tasks only); verifier (JIT); admin (break-glass) |
| `register` | Assets, parcels, holdings, findings, risk scores | Analysts on assigned tasks (scoped to asset type); verifier (JIT) |
| `evidence` | Document metadata, extraction records, examiner results | Analysts on assigned tasks; verifier (JIT) |
| `ops` | Engagements, tasks, recovery cases, partner packets, payments, consents | Staff by assignment |
| `config` | Rule packs, fee schedules, thresholds, source registries | Read: all services; write: admin with review |
| `audit` | Append-only, hash-chained access and change log | Admin and DPO read-only |
| `vault` (V1) | Sealed blobs, share metadata, release maps, trigger events | Vault service only |
| `monitor` (V1) | Pseudonymised parcel geometry and holding IDs, detections | Monitoring service; triage analysts |

The `identity` and `register` schemas are linked only by `family_id` and `person_id` UUIDs. No table outside `identity` stores a name.

### 5.2 Core tables (MVP)

Columns abbreviated. All tables carry `id uuid pk`, `created_at`, `updated_at`, `created_by`. Columns marked 🔒 are encrypted at the application layer (§8.2).

**identity**
- `families` (id, code_name, status) — `code_name` is a random label used in all staff UIs instead of the family surname.
- `persons` (id, family_id, role [principal|spouse|heir|executor|other], display_name 🔒, dob 🔒, contacts 🔒, kyc_status, kyc_ref_hash)
- `identity_variants` (id, person_id, variant_type [alias|maiden|initials|historic_address|old_employer], value 🔒, normalised_value_hash)

**ops**
- `engagements` (id, family_id, product [health_check|trace|retainer|heir], scope_json, fee, currency, status, assigned_analysts[], verifier_id)
- `consents` (id, engagement_id, person_id, category, text_version, granted_at, method, withdrawn_at)
- `letters_of_authority` (id, engagement_id, target_type [registrar|bank|land_registry|other], target_name, signed_doc_id, valid_until)
- `tasks` (id, engagement_id, type, asset_scope, assignee, status, due_at)
- `recovery_cases` (id, engagement_id, asset_id, type [dividend|dormant|mandate|title], owner_party, status, sla_due_at, outcome_value, outcome_evidence_id)
- `partner_packets` (id, engagement_id, partner_id, packet_type, asset_ids[], file_id, issued_at)
- `partners` (id, type [law_firm|trustee|surveyor|vetting|bank], name, contact, agreement_ref)
- `payments` (id, engagement_id, provider, provider_ref, amount, currency, status)

**register**
- `assets` (id, family_id, type, description 🔒, owner_of_record_person_id, value_band, verification_status [claimed|evidenced|verified|disputed], status_reason)
- `parcels` (asset_id pk/fk, state, lga, locality, geometry geography(Polygon) 🔒*, title_doc_type, title_ref 🔒, charting_result, gazette_status, encumbrances_json, occupation_status, risk_score, risk_band, rule_version, scored_at)
- `holdings` (asset_id pk/fk, holding_type [shares|account|rsa|policy|private_stake|receivable|offshore], institution, reference 🔒, quantity 🔒, last_known_date)
- `findings` (id, family_id, type [gap|risk|recoverable|exposure], severity, summary 🔒, asset_ids[])
- `asset_evidence` (asset_id, evidence_item_id, field_name, relation [supports|contradicts])

*Geometry is stored encrypted in `register`; a pseudonymised copy without owner linkage is created in `monitor` for V1 monitoring. PostGIS operations in MVP run on decrypted geometry in memory within the job runner.

**evidence**
- `documents` (id, family_id, doc_class, storage_path, sha256, page_count, uploaded_by, source [client|registry|registrar|bank|surveyor], retention_until)
- `extractions` (id, document_id, model, prompt_version, schema_version, fields_json 🔒, confidence_json, created_at)
- `examinations` (id, extraction_id, model, prompt_version, result [pass|mismatch|unreadable], mismatches_json 🔒)
- `evidence_items` (id, document_id, page, field_name, value 🔒, extraction_id, examination_id, resolved_by, resolution)

**verification**
- `verifications` (id, engagement_id, preparer_id, verifier_id, checklist_json, statement_template_version, signed_at, signature_ref, report_file_id)
  - DB constraint: `preparer_id <> verifier_id`.

**config**
- `config_versions` (id, pack [title_rules|fee_schedule|match_thresholds|source_registry], jurisdiction, version, content_yaml, sha256, effective_from, approved_by)

**audit**
- `events` (id, ts, actor_id, actor_role, action, object_type, object_id, family_id, reason, ip_hash, prev_hash, hash)

### 5.3 V1 tables (design level)

- `vault.vaults` (id, family_id, version, sealed_blob_ref, blob_sha256, dek_wrap_scheme, created_at)
- `vault.key_shares` (id, vault_id, holder_type [principal|lawyer|heirline], holder_id, share_ref, wrapped_with)
- `vault.release_maps` (id, vault_id, recipient_person_id, scope [executor_pack|full|category_list|contacts_only])
- `vault.trigger_events` (id, vault_id, type [death|incapacity], state, attestations_json, cooling_off_ends_at, decided_by, outcome)
- `vault.access_grants` (id, person_id, level [L0|L1|L2|L3], scope, expires_at)
- `monitor.parcels` (pseudo_id, geometry, baseline_image_ref, last_checked_at) — no `family_id`, no names; the link from `pseudo_id` to `asset_id` is held in `register` only.
- `monitor.detections` (id, pseudo_id, source, change_score, image_refs, triage_status, field_check_id)
- `monitor.reg_sources`, `monitor.reg_changes` (source, fetched_at, diff_ref, summary, tags, approved_by)

### 5.4 Retention

| Data | Default retention |
|---|---|
| Document working copies | Deleted 90 days after report delivery, unless the client opts into retention under a retainer |
| Extraction and examination records | Kept with the register while the engagement or retainer is active |
| Working register (no retainer) | Deleted 12 months after delivery; client keeps the report |
| Audit events | 7 years **[VERIFY]** against NDPA and accounting obligations |
| Consents | Life of the relationship + 7 years **[VERIFY]** |

Deletion is a scheduled job that writes an audit event per deleted object and crypto-shreds the family data key when a family is fully offboarded.

---

## 6. Authentication

- Staff: email + password with **mandatory MFA** (TOTP or passkey). Sessions expire after 8 hours; re-authentication required for JIT full-register access and for signing.
- Device posture (MVP): staff use managed laptops with disk encryption; console access only from allowlisted countries **[DECIDE]**.
- Clients, partners, heirs (V1): passwordless magic link + OTP to a second channel, or passkeys. No SMS-only auth for vault actions.
- Service-to-service: short-lived signed tokens; service role keys never reach the browser.

---

## 7. Authorisation

### 7.1 Roles

| Role | Phase | Summary |
|---|---|---|
| `admin` | MVP | Configures system, users, config packs. No routine access to client data. |
| `analyst` | MVP | Works assigned tasks within an engagement |
| `verifier` | MVP | Reviews and signs; JIT full-register access during sign-off |
| `dpo` | MVP | Reads audit log, consent register, incident records |
| `partner` | V1 | Sees issued work packets only |
| `principal` | V1 | Own family's register and vault management |
| `heir` / `executor` | V1 | Scoped by disclosure level or release map |

### 7.2 Task-scoped access (RLS)

RLS policies check an `ops.task_grants` view that resolves:
`user → active task → engagement → family → asset_scope (types or explicit asset_ids)`.

- An analyst working "registrar searches" sees `holdings` of type `shares` for that family, plus identity variants. They do not see parcels.
- An analyst working "Lagos parcel 3" sees that parcel's row and its evidence only.
- Family surnames are never displayed in task UIs; staff see `code_name`.

### 7.3 Just-in-time full-register access

- Available to `verifier` only, on an engagement where they are the assigned verifier.
- Requires: re-authentication with MFA, a typed reason, and an open sign-off task.
- Grants a time-boxed session (default 4 hours, renewable once).
- Every view of a sensitive field is written to `audit.events`.
- The owner/admin receives a content-free alert ("JIT access opened on engagement X").

### 7.4 Break-glass

Admin break-glass for incident response requires a second staff approval and is reviewed by the DPO within 48 hours.

---

## 8. Encryption and key management

### 8.1 Key hierarchy

```
KMS root key (never leaves KMS)
  └─ Family Key Encryption Key (per family, in KMS)
       └─ Data Encryption Keys (per family, per data class: identity, register, evidence)
            └─ field values and files (AES-256-GCM)
```

- DEKs are generated per family and data class, wrapped by the family KEK, stored wrapped in the DB.
- Unwrap happens only inside the server or job runner, per request, with the caller's authorisation checked first.
- **Crypto-shredding:** destroying a family KEK makes that family's data unrecoverable. Used for offboarding.

### 8.2 Field and file encryption

- Encrypted columns (🔒) store `{v, iv, ct, tag, key_ref}` as JSON or bytea. Searchable fields use a separate keyed HMAC column for equality lookup (e.g. `normalised_value_hash`).
- Files are encrypted by the server before upload to storage; storage holds ciphertext only. Downloads stream through the server, which decrypts after an authorisation check.
- Database backups are encrypted by the provider and, because sensitive fields are already ciphertext, a leaked backup does not expose them without KMS access.

### 8.3 Vault cryptography (V1)

1. At seal time, the **principal's browser** generates a random vault key and encrypts the final register export (JSON + PDF) client-side.
2. The vault key is split with a **2-of-3 threshold scheme** (Shamir secret sharing). Shares:
   - **Principal share:** wrapped with a key derived from the principal's passkey/passphrase; recoverable via a paper recovery sheet the principal stores physically.
   - **Lawyer/trustee share:** wrapped to the nominated partner's public key.
   - **Heirline share:** wrapped by a dedicated KMS key whose use is permitted only to the vault service, and only when the trigger state machine is `RELEASE_APPROVED`.
3. Heirline alone holds one share and **cannot decrypt**.
4. On release, the Heirline share combines with the lawyer's share, the vault is decrypted client-side in the executor's session, and only the parts in the release map are shown.
5. Library: an audited threshold-sharing implementation. **[VERIFY]** commission an independent cryptography review before the first real vault is sealed.

### 8.4 Trigger state machine (V1)

```
SEALED
  └─(report death/incapacity)→ TRIGGER_REPORTED
        └─(death cert/medical attestations uploaded)→ ATTESTATIONS_PENDING
              └─(lawyer attestation recorded, docs examined)→ COOLING_OFF (default 14 days;
                                                                 notices to principal's channels)
                    ├─(principal responds / any objection / doc check fails)→ HALTED → human review
                    └─(timer ends, no objection, all checks pass)→ RELEASE_APPROVED
                          └─(executor + lawyer share combine)→ RELEASED (scoped by release map)
```

- Any state can move to `HALTED`. `HALTED` requires two-person human review to resume.
- Incapacity requires two medical attestations plus a lawyer attestation.
- V2: a duress code moves the vault to `LOCKED_DURESS` silently and alerts the lawyer.

---

## 9. AI pipeline

### 9.1 AI gateway

All model calls go through one internal service. It:
1. **Redacts** before sending: replaces names, account numbers and plot references not needed for the task with stable placeholders (e.g. `[PERSON_1]`, `[ACCT_1]`) and keeps the mapping server-side.
2. **Routes** to the configured model tier per task.
3. **Enforces structured output** against a JSON Schema; invalid output is retried once, then sent to a human queue (fail closed).
4. **Logs** prompt version, model, schema version, token counts and latency to `evidence.extractions` or an AI call log. Prompt and response bodies are not logged in plain text.
5. **Applies data slicing:** each call receives only the document or record its task needs.

**Extraction exception:** vision extraction must see the document image, which contains the names on it. Those calls send the page image only, with no other family context, under the zero-data-retention terms confirmed in §4.

### 9.2 Document classification and extraction (MVP)

| Step | Model | Input | Output |
|---|---|---|---|
| Classify | Haiku | Page 1 image (downscaled) | `doc_class` ∈ {c_of_o, deed_of_assignment, governors_consent, survey_plan, receipt, family_conveyance, share_certificate, dividend_warrant, bank_statement, rsa_statement, policy, other} + confidence |
| Extract | Sonnet | Page images | Class-specific JSON schema (e.g. C of O: holder_name, file_number, registered_number, page/volume, date, location, area, survey_plan_no) + per-field confidence |
| Examine | Sonnet (Opus for high-value or conflicting) | Page images + extracted fields only (no extractor reasoning) | Per-field `match | mismatch | not_found` + notes |
| Resolve | Human (analyst) | Mismatches and low-confidence fields | Accepted values → `evidence_items` |

**Rules:**
- A field reaches `evidence_items` only if the examiner returns `match` **and** confidence ≥ threshold, or an analyst resolves it.
- Thresholds live in `config` (`match_thresholds` pack).
- Handwritten or poor-quality scans: classifier returns `unreadable` → manual entry task.

### 9.3 Cross-document consistency (MVP)

A deterministic check runs after extraction across one family's evidence:
- name on title vs principal identity variants;
- survey plan number on deed vs survey plan document;
- area and location consistency between deed, survey plan and C of O.

Inconsistencies become `findings` of type `risk`. An LLM may draft the plain-English explanation; the finding itself is rule-generated.

### 9.4 Discovery matcher (MVP)

**Candidate generation is deterministic:**
1. Normalise names: lower-case, strip diacritics (e.g. "Akómoláde" → "akomolade"), remove titles (Chief, Alhaji, Dr, Engr, Prince, Mrs), split compound names.
2. Generate variants: token reorder, initials, maiden and married names, known aliases, common transliteration variants (configurable list).
3. Score candidates against source rows with Jaro-Winkler on tokens + token-set overlap + secondary signals (address fragments, institution, era).
4. Above `auto_review` threshold → analyst queue. Below `discard` threshold → dropped. **Nothing is auto-confirmed.**

**LLM role (Sonnet):** write a one-paragraph rationale for each candidate an analyst reviews. It never sets the score.

**Sources (MVP):**
- Bank-published dormant account lists: **downloaded by an analyst and uploaded** as files, parsed by a job. No automated scraping in MVP, to avoid terms-of-service and reliability problems.
- Registrar responses: uploaded letters/emails parsed into structured rows.
- SEC/registrar portal searches: performed manually by an analyst; results recorded as evidence.

**Evaluation:** maintain a labelled set of at least 300 synthetic name pairs reflecting Nigerian naming patterns; track precision and recall per release (§14).

### 9.5 Title analyst (MVP)

- Sonnet reads one parcel's resolved evidence and produces the **rules-engine input object** (doc hierarchy level, name-match result, charting result, gazette status, encumbrances, occupation).
- The rules engine produces the score (§10).
- Sonnet then drafts the narrative for the perfection plan using the score, the rule hits and the fee estimate. The analyst edits; the verifier approves.

### 9.6 V1 / V2 agents

| Agent | Design notes |
|---|---|
| Regulatory Watch (V1) | Source registry in config; scheduled fetch; text diff; Haiku summarises; tags map to asset types; analyst approves before any alert |
| Parcel Monitor (V1) | Computer-vision change score between baseline and new imagery; Haiku drafts the triage note; field check before client notice |
| Case Ops (V2) | Reads `recovery_cases`; drafts follow-ups; humans send |
| Heir Guide (V2) | Retrieval limited to content at the heir's access level; refuses above-level questions; all turns logged |

### 9.7 Prompt and schema management

- Prompts and JSON Schemas live in the repo under `/ai/prompts/<task>/<version>.md` and `/ai/schemas/<task>/<version>.json`.
- Every model output stores `prompt_version` and `schema_version`.
- A prompt change requires the evaluation suite (§14) to pass before deployment.

---

## 10. Title-risk rules engine (MVP, Lagos)

### 10.1 Design

- Pure TypeScript library, no I/O, no LLM. Input: a typed `ParcelEvidence` object. Output: `{score, band, hits[], missing_evidence[], fee_estimate}`.
- Config pack per jurisdiction in YAML, stored in `config.config_versions`, also mirrored in the repo for review.
- Every scoring run records `rule_version` and `config sha256`. Re-scoring after a config change produces a diff for analyst review.

### 10.2 Example config shape

```yaml
pack: title_rules
jurisdiction: NG-LA
version: 2026.11.0
effective_from: 2026-11-08

document_hierarchy:          # higher = stronger
  registered_c_of_o_or_consent: 0
  unregistered_deed: 30
  survey_plan_only: 45
  receipt_or_family_conveyance_only: 60

modifiers:
  name_mismatch_on_title: +20
  charting_committed_or_acquisition: +35
  charting_not_done: +15
  under_gazette_or_excision_pending: +10
  known_encumbrance: +15
  occupation_by_third_party: +25
  occupation_unknown: +10

bands:
  - {name: low, max: 20}
  - {name: moderate, max: 45}
  - {name: high, max: 70}
  - {name: critical, max: 1000}

fail_closed:
  missing_required_inputs: [document_hierarchy, charting_result]
  on_missing: band=unscored, create_task=collect_evidence
```

All weights above are placeholders. **[DECIDE]** calibrate them with the partner law firm and surveyor before first client use.

### 10.3 Fee estimator

- Uses the `fee_schedule` pack for the jurisdiction (consent fee %, stamp duty %, registration %, other levies) applied to an **assessed value input** entered by the analyst from the current official schedule.
- Outputs a range, not a point value, and always shows the schedule version and date.
- Ranking for the perfection plan: `priority = risk_weight × value_band_weight ÷ cost_band_weight`, with weights in config.

---

## 11. Reports and partner packets (MVP)

- Templates: HTML + CSS in repo, rendered to PDF in the job runner.
- **Client report sections:** summary; verified register by asset class; title-risk table; perfection plan; recoverable funds; gaps and exposure; verification statement; methodology and limitations.
- **Partner packets:** law-firm parcel packet; trustee asset schedule. Each includes only the assets in scope.
- Every PDF is watermarked with recipient name, engagement code and issue timestamp.
- Delivery via **expiring signed links** (default 7 days, single recipient, download count logged). No PDFs attached to email or WhatsApp.
- Verification statement text is versioned; the PDF records the version.

---

## 12. Integrations

| Integration | Phase | Direction | Notes |
|---|---|---|---|
| Paystack | MVP | In (webhooks) | Verify webhook signatures; idempotent handlers |
| Stripe | MVP | In (webhooks) | As above |
| Resend | MVP | Out | Content-free templates; no asset data |
| Identity verification provider | MVP | Out/in | **[DECIDE]** provider; store result + hash only |
| E-signature | MVP | Out/in | **[DECIDE]** provider vs in-app OTP signing |
| Lagos e-GIS / land registry | MVP | Manual | Analyst-operated searches; results uploaded as evidence. No automated integration in MVP. |
| Registrars, banks | MVP | Manual | Letters generated by Heirline, sent by staff or lawyers; responses uploaded |
| Imagery provider | V1 | In | **[DECIDE]** very-high-resolution commercial provider; pilot on 20 parcels for cost and accuracy |
| WhatsApp Business API | V1 | Out | Nudges only |
| Partner portal | V1 | Out | Scoped, time-limited access |

---

## 13. Non-functional requirements

| Area | Requirement |
|---|---|
| Availability | Internal console 99.5% monthly (MVP). Vault release path 99.9% with a manual fallback procedure (V1). |
| Backup and recovery | Daily encrypted backups + point-in-time recovery; RPO ≤ 24 h, RTO ≤ 8 h (MVP). Quarterly restore test. |
| Performance | Extraction of a 10-page document < 3 min p95; report generation < 2 min p95. Console pages < 1.5 s p95. |
| Scale (MVP) | 50 families, 2,000 documents, 5 staff users. Design should reach 1,000 families without re-architecture. |
| Data residency | **[VERIFY]** hosting region options; document the NDPA transfer basis for any processing outside Nigeria. |
| Accessibility | Client-facing pages meet WCAG 2.1 AA (V1). |
| Browser support | Latest two versions of Chrome, Safari, Edge; mobile Safari and Chrome for client views (V1). |
| Localisation | English only at launch; currency display NGN and USD. |

---

## 14. Security, privacy and compliance controls

### 14.1 Controls checklist

- [ ] MFA enforced for all staff; no shared accounts.
- [ ] RLS on every table; automated RLS tests in CI (a policy without a test fails the build).
- [ ] Service role key server-side only; secrets in the platform secret store; quarterly rotation.
- [ ] Application-layer encryption for 🔒 fields and all files.
- [ ] AI gateway redaction and zero-data-retention terms confirmed before processing client data.
- [ ] Audit log append-only with hash chaining; weekly integrity check job.
- [ ] Content-free notification templates enforced by a template allowlist.
- [ ] Analytics and error tooling scrub PII; request bodies never captured.
- [ ] Staff device policy: disk encryption, screen lock, no local copies of client files.
- [ ] Dependency scanning and secret scanning in CI.
- [ ] External penetration test before the first vault is sealed (V1), then annually.
- [ ] Incident response runbook with the 72-hour NDPC notification path; tabletop exercise before launch.

### 14.2 NDPA / GAID artefacts (before the first client)

1. DPIA covering identity, register, evidence and AI processing.
2. Record of processing activities.
3. Consent texts per sensitive data category, versioned.
4. NDPC registration and DPO appointment.
5. Processor agreements with Supabase, the job runner, Anthropic, Resend, Paystack, Stripe, KYC and e-signature providers.
6. Cross-border transfer assessment.
7. Data subject request procedure (access, correction, deletion) with a 30-day target **[VERIFY]** against NDPA timelines.

---

## 15. Observability

- Structured logs with request IDs; no PII or field values.
- Metrics: job queue depth, extraction latency, examiner mismatch rate, matcher review volume, report generation failures, JIT access count.
- Alerts: failed jobs above threshold, KMS errors, RLS policy failures, unusual JIT access frequency, audit chain break.
- Weekly ops review: examiner mismatch rate and analyst override rate per prompt version.

---

## 16. Environments and delivery

| Environment | Data | Access |
|---|---|---|
| Local | Synthetic fixtures only | Developers |
| Staging | Synthetic fixtures only; separate KMS keys | Developers, testers |
| Production | Real client data | Staff by role |

- **No real client data outside production, ever**, including in bug reports and prompts used for debugging.
- CI: type checks, unit tests, RLS tests, rules-engine golden tests, schema validation tests, AI eval suite (on prompt/schema changes), dependency and secret scanning.
- Database migrations versioned in repo; production migrations require a second reviewer.
- Feature flags for V1 capabilities.

---

## 17. Testing and evaluation

| Suite | What it proves | Gate |
|---|---|---|
| Rules engine golden tests | Each config pack produces expected scores for 50+ hand-built parcel cases | Every change to engine or config |
| RLS tests | Each role/task combination sees exactly what it should, and nothing else | Every migration |
| Extraction eval | Field accuracy on a labelled set of synthetic and consented sample documents (target ≥ 98% after examiner pass on verified fields) | Every prompt or schema change |
| Matcher eval | Precision and recall on 300+ synthetic Nigerian name pairs | Every matcher or threshold change |
| Crypto tests (V1) | Seal/unseal round-trips, threshold combinations, share loss scenarios, tamper detection | Every vault change |
| Trigger state machine tests (V1) | All transitions, timers, halts and invalid paths | Every vault change |
| End-to-end | A synthetic family runs from engagement to signed report | Before each release |

**Sample documents:** build the extraction eval set from synthetic documents generated to mimic real layouts, plus real documents only with explicit written consent and redaction.

---

## 18. MVP build plan (12 weeks)

Concierge operations start in week 1 using spreadsheets and manual process; the tooling replaces manual steps as it ships.

| Weeks | Ships | Done when |
|---|---|---|
| 1–2 | Repo, environments, auth + MFA, schemas, KMS envelope encryption, audit log, RLS framework with tests | A synthetic family can be created and every access is logged |
| 3–4 | Engagements, consents, letters of authority, tasks, payments (Paystack/Stripe), document upload with encryption | First real engagement can be opened and paid in the system |
| 5–6 | AI gateway, classification, extraction, examiner, human resolution queue, evidence items | Extraction eval ≥ target on the eval set |
| 7–8 | Register, identity variants, matcher + dormant-list upload/parsing, registrar letter generator | Matcher eval meets thresholds; analysts work candidates in the console |
| 9–10 | Rules engine + Lagos config pack + fee estimator, title analyst drafting, cross-document checks, recovery cases | Golden tests pass; first real parcels scored and reviewed by a lawyer partner |
| 11–12 | Verification workflow with JIT access, report and packet generation, expiring links, retention jobs | First signed report delivered from the system end to end |

**Exit criteria for MVP:** 10 real engagements processed in the system, zero security incidents, DPIA and processor agreements complete, and a written list of V1 priorities from analyst and verifier feedback.

---

## 19. V1 technical milestones (months 3–9)

1. Client portal (register view, recovery status, alerts) with passwordless auth, delivered as a responsive web app and installable PWA (see §19.1).
2. Vault: client-side sealing, threshold shares, partner key onboarding, trigger state machine, independent crypto review, penetration test.
3. Monitoring: imagery provider pilot, pseudonymised parcel store, change detection, field-check workflow; regulatory watch with source registry.
4. Heir access levels L0–L3 and executor day-one pack (with rehearsal mode on synthetic data).
5. Partner portal and referral tracking.
6. Config packs for Ogun and FCT.

### 19.1 PWA requirements (client portal only)

- Scope: client, heir and executor portal. The staff console and marketing site are not PWAs.
- Web app manifest, icons (monogram "H"), standalone display mode.
- **Service worker caches the app shell only** (layout, fonts, icons). No register data, documents, vault blobs or API responses are cached or stored in IndexedDB/localStorage for offline use. Authenticated API responses are sent with `Cache-Control: no-store`.
- The portal must work fully in a normal browser tab. Installing is optional.
- Push notifications are opt-in and content-free ("You have an update in your Heirline portal"). iOS web push requires installation to the home screen (iOS 16.4+), so WhatsApp or email nudges linking into the portal remain the primary alert path.
- Session handling: short idle timeout, re-authentication with passkey for vault actions, sign-out clears all local state.
- Native iOS/Android apps are deferred. Revisit if clients ask for secure-enclave biometrics or the PWA install rate is too low.
- Vault keys must not depend on browser storage (see open decision 11 in §20).

---

## 20. Open technical decisions

| # | Decision | Notes |
|---|---|---|
| 1 | Job runner (Inngest vs Trigger.dev) | Choose before week 1 |
| 2 | Hosting region and NDPA transfer basis | **[VERIFY]** with Supabase and counsel |
| 3 | Zero-data-retention terms for model calls | **[VERIFY]** with Anthropic before client data |
| 4 | Identity verification provider | Must support NIN verification and return results without Heirline storing raw IDs |
| 5 | E-signature approach | Legal validity of OTP click-sign for engagement letters **[VERIFY]** with partner law firm |
| 6 | Title rule weights and bands | Calibrate with law firm and surveyor before first client |
| 7 | Imagery provider and revisit frequency | Pilot on 20 parcels; cost per parcel per year drives retainer pricing |
| 8 | Threshold-sharing library | Must be audited or independently reviewed |
| 9 | Console access geography | Allowlist countries for staff access |
| 10 | Audit and consent retention periods | **[VERIFY]** against NDPA and accounting rules |
| 11 | Vault key storage in the browser | Browsers can evict local storage (Safari does so for sites that are not installed). Derive keys from the passkey (WebAuthn PRF where supported) rather than storing them; the printed recovery sheet is the backstop. Test on iOS Safari, installed PWA and Android Chrome before the first vault is sealed. |

---

**Next artefacts (per build methodology):** MVP scope → user flow → design system → database schema (SQL migrations from §5) → CLAUDE.md → SKILL.md → wireframe brief → sequenced build prompts.
