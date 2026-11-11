# CLAUDE.md — Heirline

Read this file fully at the start of every session. It is short on purpose. Detail lives in `docs/`.

## 1. What we are building

**Heirline** (legal entity: Heirline Nigeria Limited) is a highly premium, discreet private-client service for Nigerian high-net-worth families. It finds, verifies, protects and records everything a family owns (land, shares, unclaimed dividends, dormant accounts, pensions, policies, private stakes, informal loans, offshore assets), checks land titles, recovers forgotten funds, monitors land for encroachment, keeps a sealed vault released on verified death or incapacity, and prepares heirs.

Tagline: **Verified. Protected. Ready.** Partner one-liner: "The verified asset register behind your will."

Owner: Tokunbo Akomolede (Founder/CEO). Independent verifier: Oludayo Akomolede, ICAN, signs agreed-upon-procedures statements.

Three surfaces, one design system:

| Surface | Who | Delivery | Phase |
|---|---|---|---|
| **Console** | Heirline staff and the verifier | Web only, desktop 1440px | MVP |
| **Website** | Prospects, partners | Web only, responsive | MVP (parallel track) |
| **Portal** | Principal, heirs, executor | Responsive web + installable PWA | V1 |

## 2. Non-negotiables (violating any of these is a bug)

1. **Non-custodial.** Heirline never holds client money or assets, never writes wills, never acts as trustee, never gives legal or investment advice. Legal work is always "our partner law firms" (Legal Practitioners Act s.22). The verifier's statement is **agreed-upon procedures**, never an audit opinion.
2. **Deterministic core.** Title-risk scores, fee estimates, match thresholds and vault release triggers come from versioned rules and config. **An LLM never sets a score, a threshold or a release decision.** LLMs extract, examine, draft prose and summarise.
3. **Generator / examiner separation.** Extraction and examination are separate model calls with separate prompts. The examiner never sees the extractor's reasoning.
4. **Fail closed.** Ambiguous match, failed check, missing attestation, crypto error, schema-invalid model output: block progress and create a human task. Never guess, never auto-confirm.
5. **Config is law.** Rule packs, fee schedules, thresholds and source registries are versioned config. Every output records the config version and sha256 it used.
6. **Compartmentalise.** Separate Postgres schemas (`identity`, `register`, `evidence`, `ops`, `config`, `audit`; later `vault`, `monitor`) linked only by UUIDs. **No table outside `identity` stores a name.** Staff UIs show the family `code_name` (e.g. KESTREL), never a surname.
7. **No standing full-register access.** Only the assigned verifier, on an open sign-off task, with MFA re-auth and a typed reason, in a time-boxed session (default 4 hours), every view logged.
8. **Encrypt sensitive fields at the application layer** (AES-256-GCM, envelope keys, per-family). Files are encrypted before upload. Database backups alone must never expose a sensitive field.
9. **Content-free messages.** Email, WhatsApp and push never carry names, amounts or asset details. Template allowlist enforced in code. Analytics and error tools receive no personal or asset data.
10. **No real client data outside production**, including in tests, prompts, screenshots and bug reports. Local and staging use synthetic fixtures only (the KESTREL family in `docs/06_KESTREL_Fixture.md`).
11. **Heirline alone can never decrypt a vault.** 2-of-3 key shares. In the UI the three are called **key holders**. Never "custodian".
12. **Nothing is shipped to a real client until** the DPIA, processor agreements and zero-data-retention terms are confirmed (see `docs/05_Decisions_and_Gaps.md`).

## 3. Stack (defaults; change only via `docs/05_Decisions_and_Gaps.md`)

- TypeScript end to end. Next.js (current stable, App Router), Tailwind, shadcn/ui primitives restyled to our tokens. Server actions for mutations; no client-side access to sensitive tables.
- Supabase Postgres with RLS and PostGIS. Private storage buckets holding ciphertext only.
- KMS envelope encryption (AWS KMS by default). Per-family KEK, per-family per-data-class DEKs.
- Auth: Supabase Auth, mandatory TOTP or passkey MFA for all staff.
- Job runner: **Inngest** (default). One runner for every background workflow.
- AI: Claude API (Haiku / Sonnet / Opus) through **one internal AI gateway** only. Redaction, routing, JSON-schema enforcement, logging. No direct model calls anywhere else.
- PDF: headless Chromium from the job runner. Templates versioned in repo.
- Payments: Paystack (NGN), Stripe (USD). Email: Resend. Analytics: PostHog (no PII). Errors: Sentry with PII scrubbing.
- Hosting: Vercel (app), Supabase (data).

## 4. Repo layout (target)

```
apps/
  console/        Next.js app, staff only
  web/            marketing site
  portal/         client portal (V1, PWA)
packages/
  ui/             design-system components (the only place UI primitives live)
  rules-engine/   pure TS, no I/O, no LLM
  ai-gateway/     the single choke point for model calls
  crypto/         envelope encryption, field + file helpers
  db/             migrations, generated types, RLS tests
  config-packs/   YAML rule/fee/threshold packs (mirrored into config.config_versions)
ai/
  prompts/<task>/<version>.md
  schemas/<task>/<version>.json
  evals/
reference/        READ-ONLY source of truth (prototypes, specs, brand). Never edit.
docs/             build docs (this pack)
design/tokens.css the prototype's tokens, verbatim
```

## 5. UI fidelity is a hard requirement

The three prototypes in `reference/prototypes/` (`console.html`, `portal.html`, and the multi-file website in `website/`) are **the approved design**. They are the specification for look, layout, spacing, copy and motion. The build must be visually indistinguishable from them at 1440px and 390px.

The website prototype was replaced by **v2 on 11 Nov 2026** (owner-approved): `reference/prototypes/website/` (`index.html`, `health-check.html`, `consultation.html`; read `PROTOTYPE_NOTES.md` there first). It has its own scroll choreography, which is the one approved exception to the motion rules (see `docs/03_UI_Fidelity_Spec.md` §3). The v1 website files are in `reference/prototypes/superseded/` for history only. Never build from them.

Rules:
- Load `design/tokens.css` verbatim as the global token layer. Tailwind's theme maps to these CSS variables. **Never hard-code a hex, px size, radius, shadow or duration** that has a token.
- All UI primitives live in `packages/ui`. Pages compose them; pages do not restyle them.
- Before building any screen, open the matching prototype in Playwright, screenshot it, then build, then screenshot your build at the same viewport and compare. Run `pnpm fidelity` (built in Phase 0) before finishing a screen.
- Read `.claude/skills/heirline-ui-fidelity/SKILL.md` before any UI work.
- If the prototype contains a pattern not in `packages/ui`, add it to `packages/ui` first, matching the prototype exactly.
- If you believe the prototype is wrong (accessibility, contrast, a copy fix in `docs/03_UI_Fidelity_Spec.md` §7), **flag it and ask**. Do not silently diverge.

## 6. Vocabulary and copy (apply everywhere)

- **Key holder**, never custodian. **Register**, not portfolio. **Verified**, **Evidenced**, **Claimed**, **Disputed** are the four verification statuses, in that order of strength: claimed → evidenced → verified → disputed.
- Staff screens show **code names** (KESTREL, OSPREY, HERON, MERLIN, PLOVER) and masked references like `•••• 4471`. Client screens show the principal as "Chief A." and family by first name.
- Naira amounts are shown as **ranges**. Currency: ₦ and $.
- Calm, precise, unhurried. Short sentences. **No exclamation marks, no emoji, no guarantees of outcome, amount or timeline.** No testimonials, logo strips, pricing or unsourced statistics on the website.
- Status is never colour alone: always a dot plus a small-caps label.
- Brass marks only moments of significance: signature, seal, vault, key holders, active verification. Never decorative, never body text.
- Footer / entity facts: Heirline Nigeria Limited · 26 Dipeolu Street, by Allen Avenue, Awolowo Way, Ikeja, Lagos · heirline.ng · Lagos · London.

## 7. How to work

- **Plan, then build, one phase at a time** from `docs/04_Build_Prompts.md`. Do not start a later phase early. Each phase has a "done when" gate. Show the gate passing before moving on.
- Act on sufficient information. Make the sensible call, state it in one line, and continue. Stop only for: destructive or irreversible actions, scope changes, or inputs only the owner can give (accounts, API keys, legal confirmations, `[DECIDE]` items).
- Every table gets RLS and an RLS test. A policy without a test fails CI.
- Every model call goes through the AI gateway and stores `prompt_version` and `schema_version`. A prompt change requires the eval suite to pass.
- Every scoring run records `rule_version` and config sha256.
- Every sensitive read or reveal writes `audit.events` (hash-chained, append-only).
- Migrations are versioned SQL in `packages/db/migrations`. Start from `db/migrations/` in this pack.
- Commit small, with clear messages. Keep `main` green: typecheck, unit tests, RLS tests, rules golden tests, fidelity check.
- Secrets only in the platform secret store. Never commit `.env`. Never log field values, request bodies or model prompts/responses in plain text.
- When a task touches an item marked **[DECIDE]** or **[VERIFY]** in `docs/05_Decisions_and_Gaps.md`, build behind an interface and a feature flag and record the assumption there. Do not hard-code the guess.

## 8. Definition of done (every task)

1. Behaviour matches the requirement ID in the PRD (e.g. DOC-3, TIT-1) and the flow in `docs/02_User_Flows.md`.
2. Tests written and passing (unit, RLS, golden, or eval as relevant).
3. For UI: fidelity check passes against the prototype at 1440px (console, website) or 390px (portal), reduced-motion respected, focus rings visible, 44px touch targets on mobile, body text at least 15px in the portal.
4. No hard-coded tokens, no surnames in staff UIs, no sensitive values in logs.
5. Audit events emitted where required.
6. Docs updated if a decision changed.

## 9. Where things are

- `docs/01_MVP_Scope.md` what is in and out, and the build order
- `docs/02_User_Flows.md` the flows, step by step, with states and failure paths
- `docs/03_UI_Fidelity_Spec.md` tokens, components, screen map, copy corrections, fidelity method
- `docs/04_Build_Prompts.md` the sequenced prompts to paste into Claude Code
- `docs/05_Decisions_and_Gaps.md` open decisions, assumptions, accounts and keys needed
- `docs/06_KESTREL_Fixture.md` the synthetic demo family used by prototypes, seeds and tests
- `reference/specs/` PRD v0.1, TRD v0.1 and the original design prompts (read-only)
- `.claude/skills/` three project skills: UI fidelity, security guardrails, rules and AI
