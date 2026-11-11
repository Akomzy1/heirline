# 04 — Build prompts for Claude Code

Paste these into Claude Code **in order**, one per session or sub-session. Each prompt is self-contained, tells Claude Code what to read, what to build, which prototype screens to match, and the gate that must pass before moving on.

## How to use

1. Create the repo. Unzip this pack at the repo root so `CLAUDE.md`, `docs/`, `db/`, `design/`, `reference/` and `.claude/` sit at the top level. Commit.
2. Open Claude Code in the repo root. Start in **plan mode** for each phase: read the plan, correct it, then let it build.
3. Paste one prompt at a time. Do not paste the next until the "Done when" gate has passed and you have looked at the screenshots Claude Code attaches.
4. After each phase, run the **Phase review prompt** (end of this file).
5. If a fidelity check fails, use the **Fidelity fix prompt**.
6. Keep `docs/05_Decisions_and_Gaps.md` current. Claude Code records every assumption there.

Every prompt ends with the same reporting contract: *what you built, gate results, fidelity diff ratios per screen, assumptions made, anything blocked on me.*

**Order at a glance**

| Prompt | Builds | Track |
|---|---|---|
| S0 | Repo bootstrap and pack check | — |
| 0 | Foundation, design system in code, fidelity harness | A |
| 1 | Platform: DB, crypto, auth + MFA, audit, RLS, seed | A |
| W | Website | B (parallel after 1) |
| 2 | Engagements, consents, payments, encrypted upload, tasks | A |
| 3 | AI gateway, extraction and examination, review screen | A |
| 4 | Register, matcher, dormant lists, registrar letters | A |
| 5 | Rules engine, title review, perfection plan, recovery board | A |
| 6 | Verification and sign-off, reports, secure links, audit screen | A |
| 7 | Hardening and launch checklist | A |
| C1–C4 | Portal (PWA), vault, heir and executor | C (V1, after MVP exit) |

---

## S0 — Bootstrap and pack check

~~~text
Read CLAUDE.md fully, then docs/01_MVP_Scope.md and docs/03_UI_Fidelity_Spec.md.

Do NOT write application code yet. Do this:
1. Verify the repo contains: CLAUDE.md, .claude/skills/*, docs/01..06, db/migrations/0001..0006 and 0100, db/tests, design/tokens.css, reference/prototypes/{console,portal}.html and reference/prototypes/website/ (index, health-check, consultation), reference/photography, reference/brand, reference/specs. List anything missing.
2. Open each prototype in Playwright at 1440x900 (portal also at 390x844) and confirm it loads with no page errors. Save one screenshot of each to a scratch folder (not the repo).
3. Read docs/05_Decisions_and_Gaps.md. For each [DECIDE] item that blocks Phase 0 or 1, propose the default you will use and why, in one line each. Do not block on items that can sit behind an interface.
4. Propose the monorepo layout (confirm it matches CLAUDE.md section 4), package manager (pnpm), task runner (Turborepo), Node version, and the CI jobs you will create.
5. Output a short plan for Phase 0 and Phase 1 with the files you expect to create.

Stop after the plan. Wait for my approval.
~~~

---

## Prompt 0 — Foundation, design system in code, fidelity harness

~~~text
Read CLAUDE.md, .claude/skills/heirline-ui-fidelity/SKILL.md, docs/03_UI_Fidelity_Spec.md and design/tokens.css. The three prototypes in reference/prototypes are the approved design.

GOAL: a monorepo where the design system exists in code and a fidelity harness proves it matches the prototypes.

BUILD
1. Monorepo (pnpm + Turborepo, TypeScript strict): apps/console, apps/web, apps/portal (empty Next.js shell, not routed yet), packages/ui, packages/db, packages/crypto, packages/ai-gateway, packages/rules-engine, packages/config-packs. Shared tsconfig, ESLint, Prettier, Vitest, Playwright.
2. Tokens: copy design/tokens.css to packages/ui/src/styles/tokens.css and add a CI check that the two files are byte-identical (design/tokens.css stays the source). Import it once per app. Measure the console prototype's Compact density (row height, body size, cell padding, control height) with reference/tools/inspect-prototype.mjs and add a [data-density="compact"] layer in a separate file; do not edit tokens.css.
3. Tailwind theme extension that maps ONLY to the CSS variables (semantic names: bg-page, bg-raised, text-primary, border-hairline, accent-significance, status-*, ceremonial-*, etc.). Add a lint rule or CI grep that fails on hex colours, raw px font sizes, box-shadow literals and transition durations outside tokens.css and packages/ui.
4. Fonts via next/font, self-hosted, Latin + Latin Extended: Cormorant Garamond (display, 32px+), Newsreader, Geist, Geist Mono. The token stacks already list the licensed fonts first; keep that. Expose the fonts so tokens' --font-* resolve to the loaded faces.
5. packages/ui foundation components, each with all states, Day and Evening, Comfortable and Compact: Button (Primary, Secondary, Tertiary, Ceremonial, Destructive), Input, Textarea, Select, Checkbox, OTP input (6 digits), StatusIndicator (dot + small-caps label, never a filled pill), Banner (info, warning, error, JIT), Toast (content-free), Dialog, Tabs (underline), Wordmark, Monogram, Seal (brass, with the 600ms reveal and the reduced-motion fallback), Icon set (lift SVGs from the prototype if present, otherwise draw thin-line 1.25px square-terminal icons for the list in docs/03 section 4).
6. A dev-only gallery route in apps/console at /_design showing every component and state in both themes. It must not ship in production builds.
7. Fidelity harness exactly as docs/03 section 10: packages/ui/fidelity with a screens registry, `pnpm fidelity`, pixelmatch (threshold 0.1, max 2% differing pixels), animations disabled, masked dynamic regions, side-by-side diff images in fidelity-report/, token-level computed-style assertions, motion assertions, axe scan. Register three screens now: console sign-in (1440), console MFA step (1440), website hero (1440 and 390), portal sign-in (390).
8. Build the console Sign in + MFA screens (static, no auth yet) as the first proof, using only packages/ui. Match reference/screenshots/console-signin-1440.png and the prototype.
9. CI (GitHub Actions): install, typecheck, lint (including the no-hard-coded-token rule), unit tests, tokens-identical check, fidelity.

RULES
- Never hard-code a value that has a token. Never edit anything under reference/.
- Copy and vocabulary per CLAUDE.md section 6 and docs/03 section 7.
- If the prototype and the spec disagree, trust the prototype for appearance and flag the disagreement.

DONE WHEN
- `pnpm fidelity` passes for the registered screens and writes a report.
- The no-hard-coded-token lint rule fails when I deliberately add a hex colour in a test file (prove it).
- /_design shows all components in both themes; axe reports no serious or critical violations.
- CI is green.

Report using the standard contract (built / gate results / fidelity diff ratios / assumptions / blocked).
~~~

---

## Prompt 1 — Platform: database, crypto, auth + MFA, audit, RLS, seed

~~~text
Read CLAUDE.md, .claude/skills/heirline-security-guardrails/SKILL.md, reference/specs/Heirline_TRD_v0.1.md sections 5–8 and 14, docs/02_User_Flows.md (F1, F9), and docs/06_KESTREL_Fixture.md.

GOAL: a secure platform core. Nothing client-facing yet. A synthetic family can be created and every access to it is logged.

BUILD
1. Database: use Supabase (local CLI for dev). Put db/migrations/0001..0006 into the project's migrations directory unchanged (0100 is V1: do not apply). Add a migration runner script and a CI job that runs them on a clean Postgres, then runs db/tests/10_schema_and_rls_tests.sql (on Supabase local, drop the stubs file, which only exists for plain Postgres). The suite currently passes 61/61; it must stay green. Generate TypeScript types from the schema.
2. packages/crypto: AES-256-GCM envelope encryption. KMS adapter interface with (a) an AWS KMS implementation and (b) a clearly named LocalDevKms that refuses to run when NODE_ENV=production. Key hierarchy per TRD 8.1: KEK per family in KMS; DEKs per family per data class (identity, register, evidence) wrapped and stored in crypto.family_keys. Functions: encryptField/decryptField returning/accepting the enc_blob shape {v,iv,ct,tag,key_ref}; keyed HMAC for searchable equality hashes; streaming encryptFile/decryptFile; shredFamily (destroy KEK, mark keys destroyed); a separate platform key for website leads. Tests: round trip, tamper detection (flip a byte, expect failure), wrong key, key version rotation, shred makes data unrecoverable, no plaintext ever logged.
3. Auth: Supabase Auth with mandatory MFA (TOTP and passkey). A server-side guard denies every route and server action unless the user has a row in ops.staff with active = true and mfa_enrolled = true. 8-hour sessions. Step-up re-authentication (fresh MFA within 5 minutes) for JIT access and signing. Five failed codes = lockout and an alert. Optional country allowlist behind a flag (decision 9).
4. Audit: a server helper `audit.log({action, object, familyId, reason})` writing to audit.events through the service role; a `withAudit` wrapper for any read of a sensitive field; a weekly job (Inngest) running audit.verify_chain() and alerting on a break; an on-demand verify endpoint for the Audit screen later.
5. Authorisation layer: server-side helpers mirroring the RLS rules (task-scoped access, JIT) so code and database agree; unit tests prove both agree on the db/tests fixtures.
6. Seed script (`pnpm seed:kestrel`) that loads db/seed/kestrel.fixture.json: staff accounts (analyst Bisi, verifier, admin, DPO) with test MFA enrolment, the KESTREL family and the other four engagements, persons and identity variants (encrypted through packages/crypto), 26 assets with their statuses, the five parcels, partners. Seeds only run in local and staging.
7. Console shell: role-aware sidebar (Evening) with the real navigation for each role, top bar, and the Engagements list screen (screen 2) reading real seeded data through the app, not mocks. Match the prototype. Wire Sign in + MFA from Prompt 0 to real auth.
8. Content-free notification template allowlist (a typed registry of allowed templates with a test that fails if a template has any variable other than an opaque link).
9. Job runner: Inngest. Set up the dev server, one example job, retries, and an idempotency pattern.

RULES
- Mutations only through server actions using the service role after a code-level authorisation check. The browser never talks to sensitive tables.
- Never log field values, request bodies or tokens. Add a test that greps the logger output for the seeded plaintext names.
- No real data. Staging uses separate KMS keys.

DONE WHEN
- `pnpm seed:kestrel` creates KESTREL; signing in as each role shows only what that role may see; opening any family record writes audit events; audit.verify_chain() is ok.
- DB suite 61/61 plus your new tests green in CI. A deliberately added table without RLS fails CI (prove it with the coverage function).
- Fidelity passes for Sign in, MFA and Engagements list (1440).
- Crypto tests green, including tamper detection and shred.

Report using the standard contract.
~~~

---

## Prompt W — Website (Track B, can run in parallel after Prompt 1)

~~~text
Read CLAUDE.md, .claude/skills/heirline-ui-fidelity/SKILL.md, docs/03_UI_Fidelity_Spec.md (sections 7 and 8), docs/01_MVP_Scope.md section 6, docs/02_User_Flows.md F10, and reference/specs/Heirline_Prototype_Prompts.md (P3). The approved design is the website v2 prototype in reference/prototypes/website/ (index.html, health-check.html, consultation.html). Read its PROTOTYPE_NOTES.md and BRIEF.md first, and serve it over HTTP to inspect it. Ignore reference/prototypes/superseded/.

GOAL: the marketing website in apps/web, visually identical to the prototype at 1440 and 390, with a working consultation form.

BUILD
1. Pages: Home; How it works; Services overview; four service pages on one template (Land & Paper Health Check, Continuity Retainer, Heir Readiness, Estate Asset Trace); For the diaspora; For partners; Security and privacy; About (advisory board shown as "to be announced"); Insights listing + article template (MDX); FAQ (accordion); Contact / Book a private consultation; Privacy notice; Terms of use.
2. Home: use the prototype's exact copy and its acts (docs/03 section 6, Website v2, and section 7 items 8 and 9). Rebuild its scroll choreography as React components in apps/web: layered hero, scatter and gather register, land boundary, step statuses, the sealing peak, the services rail, the folio, and the letter close. The register model (catalogue, statuses, sessionStorage) lives in one module, ported from reference/prototypes/website/js/heirline.js. Use the hero planes and photographs from reference/prototypes/website/assets. The website motion exception in docs/03 section 3 applies; the reduced-motion render must have no pinned scroll space. For all other pages, write copy in the same calm voice using the copy rules (no guarantees, no testimonials, no logo strips, no pricing, no unsourced statistics, legal work is "our partner law firms"). Mark anything you had to invent so I can review it.
3. Photography from reference/prototypes/website/assets (and reference/photography/masters for re-exports) via next/image with responsive sizes and meaningful alt text. Real logo SVGs from reference/brand in the header and footer. Footer exactly per docs/03 section 7 (address, tagline, SITE_PHONE and email hidden when env unset).
4. Consultation form (F10): the four parts on one letter, exactly as the prototype (who you are, topics pre-filled from the visitor's register, contact method and time, consent), client and server validation (zod), consent checkbox linking to the Privacy notice, honeypot + rate limiting, encrypts name and contact details with the platform key and stores in leads.consultation_requests, sends a content-free email to the team via Resend, shows the exact confirmation copy. No asset details requested. Submission is personal data: apply the 12-month retention default.
5. No third-party trackers or cookies. If analytics are added, use cookieless PostHog with no PII, and state it in the Privacy notice. Add metadata, sitemap, robots, canonical URLs, a minimal Organisation JSON-LD, and OpenGraph images using the seal.
6. Accessibility and performance: WCAG 2.1 AA, keyboard operable, focus visible; Lighthouse performance and accessibility at least 95 on Home (desktop and mobile).
7. Register fidelity screens: Home 1440 and 390, one service page 1440 and 390, consultation form 1440 and 390.

DONE WHEN
- `pnpm fidelity` passes for the registered website screens; axe clean; Lighthouse targets met.
- A test submission lands encrypted in the database and the plaintext cannot be found by querying the table.
- I can click through every page and nothing is a dead link.

Report using the standard contract and list every piece of copy you wrote that is not in the prototype.
~~~

---

## Prompt 2 — Engagements, consents, payments, encrypted upload, tasks

~~~text
Read CLAUDE.md, docs/02_User_Flows.md (F0, F2 steps 1 only), reference/specs/Heirline_PRD_v0.1.md section 7.1–7.2, TRD sections 4, 12 and 16. Match console screens 3 (Engagement overview), 4 (My tasks) and 5 (Document intake) in reference/prototypes/console.html.

GOAL: the first real engagement can be opened, consented, identity-checked, paid and have documents uploaded, all encrypted.

BUILD
1. Engagement lifecycle (F0): create a family with a random code name (unique, uppercase, generated from a wordlist of birds; never from a surname), create the engagement with product, scope, fee, currency, analysts and verifier (the DB constraint verifier_not_a_preparer must surface as a clear error). Stage machine enforced server-side: onboarding → intake → discovery → title_review → verification → delivered; each transition has explicit preconditions and writes an audit event. No skipping.
2. Engagement letter generation (HTML → PDF in the job runner; template versioned in repo; content per PRD ENG-2). E-signature behind an interface: implement in-app OTP click-sign as the default adapter with a clear TODO that the legal validity is a [VERIFY] item for the partner law firm.
3. NDPA consents per category with text_version, method and timestamp; withdrawal halts dependent tasks. Versioned consent texts live in repo (placeholder text clearly marked as needing legal review).
4. Letters of authority (registrar, bank, land registry) with validity dates.
5. Identity verification behind an interface (KYC provider is [DECIDE]); ship a MockKycProvider for local/staging and the real adapter slot. Store only the result and a salted hash, never the raw NIN.
6. Payments: Paystack (NGN) and Stripe (USD) checkout creation, webhook handlers with signature verification and idempotency (unique provider+ref), split payments for audit plus retainer, updating ops.payments and the engagement checklist. Test with provider test modes and recorded webhook fixtures, including a replayed webhook.
7. Document upload: drag-and-drop, client-side size/type checks, server-side encryption with the family evidence DEK before writing ciphertext to a private bucket, sha256 of plaintext recorded, retention_until set (90 days after delivery, updated when delivered), status chips (Encrypted ✓ etc.). Downloads stream through the server, which authorises, decrypts and audits. Virus scan hook as a job (stub ok).
8. Tasks: CRUD and the My tasks inbox grouped by due date, each showing code name and "Access: …" scope. Task scope (asset types, document ids, identity flag) feeds both RLS and the code-level authorisation helpers.
9. Screens: Engagement overview (stage bar across six stages; Checklist, Open tasks, Findings summary, Team; no asset details), My tasks, Document intake. Real data, real permissions, loading skeletons, empty and error states in calm copy.
10. Resend for email using only the content-free allowlist from Prompt 1.

RULES
- Fail closed: no uploads or task creation until consent, identity and payment checks are complete for the engagement (see F0).
- Never put a surname in any staff UI, URL, log or email.

DONE WHEN
- I can open KESTREL-like engagement end to end in staging with test payments and upload a synthetic C of O, and it sits encrypted in storage (show me the ciphertext object and that decrypting needs the app).
- Replayed payment webhook changes nothing. Withdrawn consent halts the dependent task.
- Fidelity passes for screens 3, 4 and 5; RLS and unit tests green; CI green.

Report using the standard contract.
~~~

---

## Prompt 3 — AI gateway, extraction and examination, extraction review

~~~text
Read CLAUDE.md, .claude/skills/heirline-rules-and-ai/SKILL.md, TRD section 9 (9.1, 9.2, 9.7), docs/02_User_Flows.md F2. Match console screen 6 (Extraction review) in reference/prototypes/console.html. This is the most important screen: give it the most care.

GOAL: documents are classified, extracted and independently examined; analysts resolve mismatches; only verified fields become evidence.

BUILD
1. packages/ai-gateway: the ONLY place that calls the Claude API. Implements: redaction with stable placeholders and a server-side mapping (not applied to vision extraction, which needs the image; that path sends the page image only, with no other family context); model routing per task from config (classify = Haiku, extract = Sonnet, examine = Sonnet or Opus for high-value/conflicting, narrative tasks = Sonnet); JSON-Schema enforcement with one retry then a human-queue task; per-call logging to audit.ai_calls (prompt_version, schema_version, tokens, latency, outcome; no bodies in plain text); per-call data slicing. **Fail closed: the gateway refuses to process any client document unless AI_ZDR_CONFIRMED=true is set** (zero-data-retention terms are a [VERIFY] item). Local and staging use synthetic documents only.
2. Prompts and schemas in ai/prompts/<task>/<version>.md and ai/schemas/<task>/<version>.json for: classify (doc_class enum from TRD 9.2 incl. unreadable), extract (class-specific schemas: C of O, deed of assignment, Governor's consent, survey plan, receipt, family conveyance, share certificate, dividend warrant, bank statement, RSA statement, policy), examine. Extractor returns per-field value, confidence and a normalised page bounding box (for the highlight). The examiner prompt receives the page images and the extracted fields ONLY, never the extractor's reasoning.
3. Jobs (Inngest): classify → extract → examine → route. Evidence rule: a field becomes an evidence_item only if the examiner returns match AND confidence ≥ the match_thresholds config value, or an analyst resolves it (resolved_by + resolution recorded). The DB constraint enforces this; surface its errors clearly. Unreadable → manual-entry task.
4. Extraction review screen (screen 6): split view with a document page viewer (zoom, page thumbnails, field region highlights that follow the clicked field), the extracted-fields form with confidence bars and examiner chips (Match / Mismatch / Not found), amber mismatch rows with the examiner's note, per-field Accept / Edit / Mark unreadable, footer "Accept all matched fields" and "Send to evidence", toast "Fields saved to evidence.", task leaves My tasks. Keyboard operable. Masked values and reveal-with-audit per F4.
5. Eval harness (ai/evals): a generator for synthetic documents that mimic Nigerian layouts (C of O, deed, survey plan, share certificate, dividend warrant) rendered to images with realistic noise, and a labelled set. A runner reports per-field accuracy before and after the examiner pass, mismatch rate and analyst override rate. Target: ≥98% field accuracy on verified fields. Unit tests use recorded model responses; the live eval is a manual, cost-aware command (`pnpm eval:ai`), required to pass before any prompt or schema change merges.
6. Threshold config pack `match_thresholds` published through the config mechanism (four-eyes, sha256) with the extraction confidence threshold.

DONE WHEN
- The fidelity check passes for screen 6 in its default, mismatch and resolved states.
- Run the live eval on the synthetic set and show me the accuracy table. If below target, iterate on prompts, not on thresholds.
- A schema-invalid model response is retried once, then lands in the human queue (test it). With AI_ZDR_CONFIRMED unset, the gateway refuses (test it).
- No prompt/response bodies or field values appear in logs.

Report using the standard contract and include the eval table.
~~~

---

## Prompt 4 — Register, matcher, dormant lists, registrar letters

~~~text
Read CLAUDE.md, .claude/skills/heirline-rules-and-ai/SKILL.md, TRD 9.3–9.4, PRD 7.3–7.4, docs/02_User_Flows.md F3 and F4. Match console screens 7 (Discovery matcher queue) and 8 (Register, scoped view).

GOAL: analysts build the register from evidence, and the matcher surfaces forgotten money for human decision. Nothing is ever auto-confirmed.

BUILD
1. Register: asset CRUD from resolved evidence with verification_status transitions (claimed → evidenced → verified → disputed) and rules for what evidence each transition needs; change log for every edit (audit event with before/after field names, not values); register screen with tabs by asset class (Land, Shares & dividends, Bank accounts, Pensions & policies, Private stakes, Receivables, Offshore), the scope banner ("You are seeing: Land only (task-scoped access)."), masked values and the Reveal (logged) flow with the 30-second timer (F4).
2. Identity variants (REG-3): add aliases, maiden names, initials, historic addresses; normalised_value_hash through the keyed HMAC.
3. packages/matcher (pure TypeScript): normalisation (case, diacritics, titles Chief/Alhaji/Dr/Engr/Prince/Mrs, compound names), variant generation (token reorder, initials, maiden/married names, aliases, a configurable transliteration list), scoring (Jaro-Winkler on tokens + token-set overlap + secondary signals: address fragment, institution, era), thresholds from the match_thresholds config pack (auto_review, discard). Deterministic; the LLM only writes a one-paragraph rationale per candidate and never the score.
4. Evaluation: generate at least 300 synthetic Nigerian name pairs (positives with realistic variation, hard negatives with similar surnames) and report precision and recall per run (`pnpm eval:matcher`), with thresholds chosen from the curve and recorded in config. The eval must pass before any matcher or threshold change merges.
5. Source lists: upload a dormant-account list (CSV, XLSX or PDF table) or a registrar response; a job parses it into evidence.source_rows (encrypted rows + row hash). No scraping.
6. Matcher queue screen (screen 7): candidate cards with masked identity variant vs masked source row, score bar with threshold marker, rationale, signals; Confirm match (collapses to "Confirmed" and creates a recovery case), Reject (reason required), Need more evidence (creates a task); header counter; banner "Nothing is confirmed automatically." The DB constraint requires a human decider; surface it.
7. Registrar and bank letter generator: templates for the three most common registrars (placeholders marked [DECIDE]) producing PDFs for staff or lawyers to send, plus a response log that creates source rows. "Memory prompts" interview guide as a structured page (DIS-4).

DONE WHEN
- Matcher eval table shown, meeting the thresholds we set; hard negatives do not reach the queue above threshold.
- With the KESTREL seed: four candidates appear, confirming the Bank C dormant account creates a recovery case; rejecting and "need more evidence" behave as in prototype Flow 3.
- Fidelity passes for screens 7 and 8; RLS tests prove an analyst cannot see tabs outside task scope; CI green.

Report using the standard contract and include the matcher eval table.
~~~

---

## Prompt 5 — Rules engine, title review, perfection plan, recovery board

~~~text
Read CLAUDE.md, .claude/skills/heirline-rules-and-ai/SKILL.md, TRD section 10, PRD 7.5–7.6, docs/02_User_Flows.md F5–F6, and docs/06_KESTREL_Fixture.md ("Known discrepancies"). Match console screens 9 (Parcel detail), 10 (Title perfection plan) and 11 (Recovery cases).

GOAL: deterministic, config-driven title-risk scoring and fee estimation, with the perfection plan and recovery board that use them.

BUILD
1. packages/rules-engine: pure TypeScript, no I/O, no LLM. Input: typed ParcelEvidence. Output: {score, band, hits[], missing_evidence[], fee_estimate, rule_version, config_sha256}. YAML packs validated with zod, loaded from config.config_versions, mirrored in packages/config-packs. Implement the Lagos pack structure in TRD 10.2 (document hierarchy, modifiers, bands, fail_closed). Missing required inputs (document_hierarchy, charting_result) → band `unscored` and a collect_evidence task. Fee estimator per TRD 10.3: ranges only, with schedule version and date, using an assessed value entered by the analyst.
2. Weights are placeholders. Ship two packs: `NG-LA 2026.11.0-calibration-pending` (TRD placeholder values) and a DEMO pack that reproduces the prototype's Lekki parcel 2 = HIGH (58). Label the demo pack "DEMO ONLY — not calibrated" in the UI wherever its version is shown. Calibration with the partner law firm and surveyor is a blocking [DECIDE] before first client use.
3. Golden tests: at least 50 hand-built parcel cases covering every document tier, each modifier, each band edge, fail-closed paths and conflicting inputs. Add property tests (score never decreases when a risk modifier is added). Re-scoring after a config change creates a score run (register.parcel_score_runs) and a diff for analyst review; it never silently overwrites.
4. Config publishing: admin proposes, a second person approves (DB enforces), sha256 recorded; UI for viewing versions and the re-score diff.
5. Title analyst (Sonnet via the gateway): reads one parcel's RESOLVED evidence and produces the ParcelEvidence object (validated); it never sets a score. Deterministic cross-document consistency checks (name on title vs identity variants; survey plan number on deed vs survey plan; area and location across deed, survey plan and C of O) create `risk` findings; an LLM may draft the plain-English explanation only.
6. Parcel detail (screen 9): simple parcel outline map drawn as SVG from the encrypted geometry in memory, **no third-party map tiles** (they would leak client locations); title summary; evidence links; risk card (large band label, rule-hit breakdown, rules version); fee estimate card (ranges, schedule date); "Add to perfection plan".
7. Perfection plan (screen 10): ranked table using risk_weight × value_band_weight ÷ cost_band_weight (weights in config), narrative drafted by Sonnet from score + hits + fee estimate, editable inline, approved by the verifier.
8. Recovery board (screen 11): kanban with the six columns, cards with type, owner party, SLA timer and value band; drag to move (also a keyboard/dropdown alternative); moving to Recovered requires an outcome value and an evidence item (DB constraint); SLA resets on move.

DONE WHEN
- All golden tests pass; the demo pack yields HIGH (58) for Lekki parcel 2 with the exact hit breakdown the prototype shows; Ijebu-Ode shows unscored until charting is entered, then scores.
- Fidelity passes for screens 9, 10, 11; recovery drag works with the keyboard alternative; CI green.
- No LLM call is reachable from the rules-engine package (add a dependency-boundary lint rule).

Report using the standard contract.
~~~

---

## Prompt 6 — Verification and sign-off, reports, secure links, audit log

~~~text
Read CLAUDE.md, .claude/skills/heirline-security-guardrails/SKILL.md, TRD 7.3, 11, PRD 7.7–7.8 and CX-1, docs/02_User_Flows.md F7–F9. Match console screens 12 (Verification and sign-off), 13 (Reports and packets) and 14 (Audit log). Screen 12 is the signature moment: build it with the most care.

GOAL: the verifier signs an agreed-upon-procedures statement under just-in-time access, and a watermarked report is delivered by an expiring link.

BUILD
1. JIT access (F7): "Begin sign-off" requires step-up MFA and a typed reason (≥10 characters; DB-enforced); creates ops.jit_sessions (4h, one renewal); brass JIT banner with a live countdown and "All views logged"; every sensitive view during the session writes register.viewed audit events; expiry closes access immediately and signing then needs fresh step-up; content-free alert to the owner/admin.
2. Checklist per asset class generated from the engagement's assets; progress fills as items are ticked; "Sign statement" (Ceremonial) disabled with "Preparer and signer must be different people ✓ · Checklist incomplete" until complete. The database guard (ops.guard_sign) is the real gate: show its errors as calm messages.
3. Statement: versioned template in repo using agreed-upon-procedures wording (what was checked and what was found; explicitly not an audit opinion; no guarantees); signer name, ICAN reference (masked in UI as "ICAN •••• 3318") and timestamp; confirmation dialog with the summary; on confirm, the brass seal settles with the 600ms reveal and the signature line fills; stage → Delivered; toast "Statement signed. Report ready." The ICAN practice-rule check is a [VERIFY] item: gate the real signing path behind a config flag that stays off until counsel/ICAN confirms; the demo path works in staging.
4. Report generation (job runner, headless Chromium): client report sections per TRD 11 (summary; verified register by asset class; title-risk table; perfection plan; recoverable funds; gaps and exposure; verification statement; methodology and limitations). Templates are HTML+CSS in repo using the design tokens, styled as a private-bank document (cover with the seal and guilloche watermark, Cormorant/Newsreader, hairlines). Every PDF is watermarked with recipient, engagement code and issue timestamp. Partner packets (law-firm parcel packet, trustee asset schedule) contain only assets in scope (PAR-1, PAR-2). Record the statement template version, rule versions and config sha256 in the report.
5. Secure links (F8): create a link (single recipient, 7-day expiry enforced by DB, hashed token, download count), revoke, and the public download route that streams through the server with decrypt + audit. No PDF is ever attached to email or WhatsApp; the only message is a content-free email with the link.
6. Reports and packets screen (13) with watermark preview, expiry, downloads and Revoke link.
7. Audit log screen (14) for admin and DPO: filters (code name, actor, action, date), newest first, "Audit chain verified ✓" from audit.verify_chain() on demand and the weekly job; integrity break raises an alert.
8. Retention jobs: documents deleted 90 days after delivery (unless a retainer opts in), working register 12 months, each deletion audited; family offboarding runs crypto-shredding (destroy KEK). Retention periods for audit and consents stay [VERIFY] flags in config.

DONE WHEN
- End to end on KESTREL (staging): analyst prepares → verifier begins sign-off → ticks checklist → signs → report generated → secure link created → downloaded once → revoked. Every step appears in the audit log and the chain verifies.
- A preparer cannot sign (DB and UI). A JIT session that expires mid-sign blocks the signature. An expired or revoked link returns a calm error and logs the attempt.
- Fidelity passes for screens 12 (default, ticked, signed, seal revealed), 13 and 14; the seal animation measures 600ms with the ceremony easing and is instant under reduced motion.
- CI green.

Report using the standard contract and attach the generated sample report PDF (synthetic).
~~~

---

## Prompt 7 — Hardening and launch checklist

~~~text
Read CLAUDE.md, TRD sections 13–17, docs/05_Decisions_and_Gaps.md (launch checklist).

GOAL: make the MVP safe to put real client data into. Do not add features.

DO
1. Security review of the whole repo against TRD 14.1: MFA, RLS coverage, service-role key containment (grep the client bundles), encryption of every 🔒 column and all files, AI gateway redaction and the ZDR gate, audit chain, content-free templates, PII scrubbing in Sentry and PostHog, dependency and secret scanning in CI. Fix what you find; list what you cannot fix.
2. Threat-model walkthrough using PRD section 9: insider, stolen laptop, leaked backup, malicious upload, prompt injection in documents (add tests with injected instructions inside synthetic documents; the pipeline must never act on them), webhook forgery, link guessing.
3. Backup and restore: document and run a restore test; RPO ≤ 24h, RTO ≤ 8h.
4. Performance: seed 50 families and 2,000 documents; measure console pages (<1.5s p95), extraction of a 10-page document (<3 min p95), report generation (<2 min p95). Fix regressions.
5. Observability per TRD 15: structured logs without PII, metrics, alerts (failed jobs, KMS errors, RLS failures, unusual JIT frequency, audit chain break).
6. Runbooks in docs/runbooks: incident response with the 72-hour NDPC notification path, break-glass (two staff approvals, DPO review within 48h), key rotation, restore, offboarding/crypto-shred, data subject requests (access, correction, deletion).
7. Accessibility audit of every console screen (axe + manual keyboard pass) and a final fidelity run across all registered screens.
8. Generate docs/launch-checklist.md from docs/05 with each [DECIDE]/[VERIFY] item, its owner, status and evidence link. Items I must do (legal, accounts, DPIA, NDPC registration, processor agreements, pen-test booking) are listed separately.

DONE WHEN
- A pen-test-ready build exists, all tests and fidelity runs are green, and the launch checklist shows exactly which non-code items still block the first real client.

Report using the standard contract.
~~~

---

## Track C — Portal, vault, heirs (V1, only after the MVP exit criteria)

Spec: `reference/prototypes/portal.html` (mobile 390 in the phone frame; desktop Home at 1440). Apply `docs/03` §5: Day theme, Comfortable density, **Evening for vault screens**.

### C1 — Portal shell, auth, PWA, Home, Register, Land detail

~~~text
Read CLAUDE.md, docs/03_UI_Fidelity_Spec.md, docs/02_User_Flows.md (Portal flows P1, P2, P8), TRD 6 and 19.1. Apply db/migrations/0100 only for the tables this prompt needs and write their RLS policies and tests first.

BUILD apps/portal: passwordless passkey sign-in (magic link + OTP to a second channel as fallback; no SMS-only auth for vault actions); principal Home with the four summary cards in display-serif figures; bottom navigation (Home, Register, Alerts, Vault, More); Register by asset class; Land plot detail with plain-language title status, "Your lawyer is applying for Governor's Consent — step 2 of 4", cost range and where the originals are kept; desktop Home at 1440 in the editorial two-column layout. Copy: "Each one is in hand" for items needing attention.

PWA per TRD 19.1: manifest with the monogram, standalone display; service worker caches the APP SHELL ONLY; authenticated responses use Cache-Control: no-store; nothing sensitive in IndexedDB/localStorage; short idle timeout; sign-out clears local state; works fully in a normal tab. Push is opt-in and content-free. Client views read only what the principal is entitled to; add RLS for principal/heir roles with tests.

Register fidelity screens at 390 (and Home at 1440). DONE WHEN fidelity passes, axe is clean, Lighthouse PWA/a11y pass, and a test proves no register data is present in any cache or storage after use.
~~~

### C2 — Alerts, land watch, recovery tracker

~~~text
Read docs/02_User_Flows.md P3–P4, TRD 9.6 and 12 (imagery provider is [DECIDE]). Build the content-free notification path (email/WhatsApp nudge "You have an update in your Heirline portal"), the alert screen with before/after satellite compare (draggable divider, keyboard operable), the "I don't recognise this" bottom sheet ("A surveyor will visit within 7 days. Your lawyer has been informed.") and status progression to "Field visit scheduled", and the recovery tracker with item timelines. Monitoring runs on pseudonymised parcels (monitor schema, no names). Use the placeholder satellite images behind an ImageryProvider interface until a licensed provider is chosen. Match the prototype at 390; fidelity must pass.
~~~

### C3 — Family vault (the emotional core: most care)

~~~text
Read CLAUDE.md, TRD 8.3–8.4, 19.1 and open decision 11, docs/02_User_Flows.md P5 and the state machine. Match the portal's Family vault and Who sees what screens exactly (Evening theme, brass seal, key-holder diagram). Label the three as KEY HOLDERS: You, your lawyer, Heirline.

BEFORE CODE: write the cryptographic design as docs/vault-design.md (client-side sealing in the principal's browser, 2-of-3 threshold sharing with an AUDITED library, Heirline's share wrapped by a KMS key usable only by the vault service when the state is RELEASE_APPROVED, principal share wrapped by a key derived from the passkey via WebAuthn PRF where supported with the paper recovery sheet as backstop, no vault keys in browser storage). Stop and wait for my approval; an independent cryptography review is commissioned before any real vault is sealed.

THEN BUILD: the pure, table-driven trigger state machine with exhaustive transition tests (all states, timers, halts, invalid paths); the vault service; sealing and re-sealing as new versions with hash anchoring and the slow seal animation; Who sees what with level selectors L0–L3, an exact confirmation sheet describing what the heir will now see, and passkey confirmation; share-loss and tamper tests. Test on iOS Safari (including installed PWA) and Android Chrome. Fail closed everywhere.
~~~

### C4 — Heir view, executor release, day-one pack, will health check

~~~text
Read docs/02_User_Flows.md P6–P7 and the Will health check section, PRD 7.11–7.13a. Build the heir view (optional welcome note, categories without values or locations, Who to contact, two learning cards), executor release in progress (vertical timeline Death reported → Documents checked → Lawyer confirmed → Waiting period (day 9 of 14) → Release, with the calm explanation of why the waiting period exists), the seal opening on release, the executor day-one pack (asset schedule, where the originals are, who to call, claims to make with status, ticking probate checklist, watermarked PDF download with confirmation), a rehearsal mode on synthetic data, and the Will health check (partner law firm checklist via scoped packet; store the checklist outcome and attestation only, never the will's contents; register-to-will reconciliation findings; status line in the portal and the executor pack). Heirline never drafts or opines on a will. Fidelity must pass at 390.
~~~

---

## Fidelity fix prompt (use whenever `pnpm fidelity` fails)

~~~text
`pnpm fidelity` failed for <screen id>. Open fidelity-report/<screen id>.diff.png and the prototype side by side. For each visible difference: read the prototype's real values with reference/tools/inspect-prototype.mjs, find which token or component is wrong, fix it in packages/ui (not in the page), and rerun. Do not raise the diff threshold and do not mask regions to make it pass unless the region is legitimately dynamic (date, timer, prototype controls). Show me before/after screenshots and the new diff ratio.
~~~

## Phase review prompt (run after every phase)

~~~text
Act as a sceptical reviewer who has not seen this work. Review the last phase against CLAUDE.md section 2 (non-negotiables), the relevant PRD/TRD requirement IDs, and docs/02_User_Flows.md. Check specifically: any LLM influence on a score, threshold or release decision; any path that auto-confirms; any missing fail-closed branch; any sensitive value in logs, URLs or analytics; any table without a policy test; any surname in a staff UI; any hard-coded token; any copy that guarantees an outcome or uses "custodian". Run the full test suite and `pnpm fidelity`. List findings by severity with file and line, fix the high ones, and report what remains.
~~~
