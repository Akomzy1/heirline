# 05 — Decisions, assumptions, accounts and the launch checklist

Claude Code keeps this file current. Every time it makes an assumption behind an interface, it records it here. **Items marked ⛔ block the first real client.**

## 1. Technical decisions: defaults chosen so building can start

| # | Decision (TRD §20) | Default used in the build | Who decides / when |
|---|---|---|---|
| 1 | Job runner | **Inngest** | Owner, before Phase 1. Change is contained to `packages/jobs`. |
| 2 | Hosting region and NDPA transfer basis | Build on Supabase's closest available region; document the cross-border transfer basis | ⛔ Owner + counsel before real data |
| 3 | Zero-data-retention for model calls | Gateway **refuses client documents unless `AI_ZDR_CONFIRMED=true`** | ⛔ Owner confirms terms with Anthropic before real data |
| 4 | Identity verification provider (NIN-based) | `MockKycProvider` behind an interface; store result + salted hash only | Owner picks provider before first client |
| 5 | E-signature | In-app OTP click-sign behind an interface | ⛔ Partner law firm confirms legal validity |
| 6 | Title rule weights and bands | Two packs: calibration-pending TRD placeholders, and a DEMO pack reproducing the prototype's HIGH (58) | ⛔ Calibrate with partner law firm + surveyor |
| 7 | Imagery provider | `ImageryProvider` interface; placeholder satellite images | V1; pilot on 20 parcels |
| 8 | Threshold-sharing library | Chosen in `docs/vault-design.md` (Track C) | ⛔ Independent crypto review before the first vault is sealed |
| 9 | Console country allowlist | Off, behind a flag | Owner |
| 10 | Audit and consent retention | 7 years in config, flagged `[VERIFY]` | ⛔ Counsel |
| 11 | Vault keys in the browser | Derive from passkey (WebAuthn PRF where supported); printed recovery sheet as backstop; nothing in browser storage | Track C; test on iOS Safari and Android |

## 2. Product and business decisions (PRD §19)

| # | Item | Status |
|---|---|---|
| 1 | Name clearance: CAC availability for "Heirline Nigeria Limited"; heirline.ng, heirline.com.ng, heirline.com; trademark searches (Nigeria, UK) | ⛔ Open. The website footer and email addresses assume heirline.ng. |
| 2 | Does AkomzyAi build under a services agreement with the new entity? | Open |
| 3 | ICAN practice rules for the verifier signing client statements | ⛔ Open. The real signing path stays behind a config flag until confirmed. |
| 4 | Success fees on recovery (permissible and safe?) | Open. Not built. |
| 5 | Launch geography | Default Lagos only. Ogun and FCT packs are V1. |
| 6 | Imagery provider | V1 |
| 7 | Hosting region / NDPA transfer basis | See above |
| 8 | Partner economics | Open |
| 9 | Diaspora assets (coordinate foreign counsel only vs catalogue) | Default: catalogue, coordinate with UK counsel |
| 10 | Proprietary survey data | Open. Marketing must not use unsourced statistics. |

## 3. Brand and content items still open

| Item | Notes |
|---|---|
| Licensed fonts (Canela, Tiempos, Söhne) | Prototypes use Cormorant Garamond, Newsreader and Geist. Tokens already list the licensed faces first. Decide before launch; wiring them is a one-line loader change. |
| Seal text "EST. 2026" | **[VERIFY]** against the real incorporation year. The seal SVGs in `reference/brand` carry the text. |
| Hero photograph resolution | **Resolved in website v2** (11 Nov 2026): new 4K hero and a new deed image with no crest or stamp artefacts. Masters in `reference/photography/masters/`. |
| Website v2 motion clips | Optional. Two scroll-scrubbed clips were approved ("evening falls" on the lagoon, an aerial drift over the plots), but not generated because the Higgsfield account hit its grace-period daily limit. The page already delivers both moments in code. If added: desktop only, dense-GOP encode, stills on phones. |
| Website register (signature interaction) | Visitors may mark asset categories, or add their own under "Something else" (a free-text label of up to 40 characters). The selection and label stay in `sessionStorage`. Only the chosen topic chips are submitted, never the label. Add one line to the Privacy notice and the DPIA. |
| Website phone number and mailbox | Prototype phone `+234 1 234 5678` is a placeholder. Set `SITE_PHONE`; the line hides if unset. Confirm `enquiries@heirline.ng` exists. |
| NIPOST 11-character digital postcode (rolls out from 1 October 2026) | Not in the schema. If wanted, add an **optional encrypted field** on parcels and persons in the MVP, integrate in V1, and keep it **out of the pseudonymised monitoring schema**. Owner has not confirmed; do not build until confirmed. |
| Advisory board names | Shown as "to be announced" on the About page. |
| Consent, engagement-letter and privacy texts | Placeholders in repo. ⛔ Must be reviewed by counsel. |
| Will health check data model | Tables exist in `0100` (V1). TRD §5.3 is not yet updated; update it when Track C starts. |

## 4. Differences between this pack and the TRD (so nothing surprises you)

- **Added tables** needed to build the described behaviour: `crypto.family_keys`, `ops.staff`, `ops.match_candidates`, `ops.perfection_plans` and `_items`, `ops.reports`, `ops.report_links`, `ops.verification_items`, `ops.jit_sessions`, `register.parcel_score_runs`, `evidence.source_rows`, `audit.ai_calls`, `leads.consultation_requests`. Update TRD §5.2 to match.
- **Geometry** is stored as encrypted GeoJSON (`geometry_enc`) in the MVP, so PostGIS is not needed until the V1 monitor schema. The parcel map in the console is an SVG drawn from decrypted geometry in memory, with no third-party map tiles.
- **Website leads** are encrypted with a platform key, not a family key.
- **DB-level rules** beyond the TRD: engagement-level preparer ≠ verifier; evidence needs an examiner match or a human resolver; recovery cannot be "recovered" without outcome + evidence; matcher decisions need a human; report links cap at 7 days; config packs are immutable once approved and need a second approver; signed verifications are immutable.
- The prototype and TRD weights differ for "name mismatch on title" (+18 vs +20). See `docs/06_KESTREL_Fixture.md`.

## 5. Accounts, keys and environment variables you must provide

Create these yourself (Claude Code cannot). Store in the platform secret store, never in the repo.

| Need | Used for | Env vars (suggested names) |
|---|---|---|
| Supabase project (local CLI for dev; staging; production) | DB, auth, storage | `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY` (server only) |
| AWS KMS (separate keys per environment) | Envelope encryption | `AWS_REGION`, `KMS_ROOT_KEY_ID`, `KMS_LEADS_KEY_ID` |
| Anthropic API key + confirmed zero-data-retention terms | AI gateway | `ANTHROPIC_API_KEY`, `AI_ZDR_CONFIRMED` |
| Inngest | Jobs | `INNGEST_EVENT_KEY`, `INNGEST_SIGNING_KEY` |
| Paystack (NGN) and Stripe (USD), test and live | Payments | `PAYSTACK_SECRET_KEY`, `PAYSTACK_WEBHOOK_SECRET`, `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET` |
| Resend (verified sending domain) | Content-free email | `RESEND_API_KEY`, `MAIL_FROM` |
| KYC provider | Identity checks | `KYC_PROVIDER`, `KYC_API_KEY` |
| Sentry, PostHog (no PII) | Errors, analytics | `SENTRY_DSN`, `POSTHOG_KEY` |
| Vercel project(s) | Hosting | per app |
| Site details | Website footer | `SITE_PHONE`, `SITE_EMAIL` |

## 6. Launch checklist: what blocks the first real client

**Legal and compliance (owner + counsel, not code)**
- [ ] ⛔ DPIA covering identity, register, evidence and AI processing
- [ ] ⛔ Record of processing activities
- [ ] ⛔ Consent texts per sensitive data category, versioned and reviewed
- [ ] ⛔ NDPC registration and DPO appointment
- [ ] ⛔ Processor agreements: Supabase, Inngest, Anthropic, Resend, Paystack, Stripe, KYC, e-signature
- [ ] ⛔ Cross-border transfer assessment
- [ ] ⛔ Data subject request procedure (30-day target [VERIFY])
- [ ] ⛔ Engagement letter and statement wording reviewed by the partner law firm (AUP, non-custodial, LPA s.22)
- [ ] ⛔ ICAN practice-rule position for the verifier
- [ ] ⛔ Partner law firm and surveyor agreements; title-rule calibration signed off
- [ ] CAC name, domains, trademarks

**Technical (Claude Code, Prompt 7)**
- [ ] Zero-data-retention confirmed and `AI_ZDR_CONFIRMED=true` in production only
- [ ] MFA enforced; no shared accounts
- [ ] RLS coverage and tests green; service-role key absent from client bundles
- [ ] Encryption verified for every 🔒 column and all files
- [ ] Audit chain verified; weekly integrity job live
- [ ] Backups and a tested restore (RPO ≤ 24h, RTO ≤ 8h)
- [ ] Penetration test booked (required before the first **vault** is sealed in V1, annually after)
- [ ] Incident runbook and a tabletop exercise (72-hour NDPC path)
- [ ] Final fidelity run and accessibility audit

**Brand and content**
- [x] Hero replaced at 4K; deed image replaced (website v2)
- [ ] Fonts licensed or fallbacks accepted
- [ ] Seal year confirmed
- [ ] Website copy reviewed (no guarantees; no unsourced statistics)

## 7. Assumption log (Claude Code appends here)

| Date | Phase | Assumption | Where it lives | Revisit when |
|---|---|---|---|---|
| 11 Nov 2026 | Pre-build | Owner approved website prototype v2. It replaces v1 as the website spec, with a website-only motion exception. Console and portal unchanged | `reference/prototypes/website/`, docs/03 §1, §3, §6, §7 | Before Prompt W |
| 11 Nov 2026 | Pre-build | Website shows no market statistics: the sourced-figures research did not complete | `scrollcraft/builds/heirline/reports/` | When sourced figures exist |
