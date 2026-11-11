# 01 — MVP scope and build order

## 1. The one-line scope

The MVP is **internal tooling for a concierge service**. Heirline staff and the verifier use the **Console** to take a family from engagement to a **signed, delivered report**. Clients see a report and a secure expiring link, not software. The **Website** ships in parallel. The **Portal, vault and monitoring** are V1.

## 2. Reconciling the TRD with the prototypes

The TRD says "no client portal in the MVP". The prototypes include a full portal. Both are right:

- **Build the portal after the MVP exits**, using `reference/prototypes/portal.html` as the spec. Do not start it earlier.
- **Build the website early.** It has no sensitive data, it is the lowest risk, it gives partners and prospects something to see, and it proves the design system in code.

| Track | What | Starts | Spec |
|---|---|---|---|
| **A. Console (MVP)** | Staff and verifier tooling, engagement → signed report | Phase 0 | `reference/prototypes/console.html`, PRD §7, TRD §5–11 |
| **B. Website (MVP, parallel)** | Marketing site, consultation form | After Phase 1 | `reference/prototypes/website/` (v2) |
| **C. Portal (V1)** | Client, heir, executor portal as PWA, vault, monitoring | After MVP exit criteria | `reference/prototypes/portal.html`, TRD §19 |

## 3. In scope for the MVP (Track A)

Requirement IDs refer to `reference/specs/Heirline_PRD_v0.1.md`.

| Area | IDs | What ships |
|---|---|---|
| Engagement and consent | ENG-1 to ENG-6 | Engagement per family with scope, product, fee, team. Engagement letter. Versioned NDPA consents per data category. Letters of authority. Identity verification. Payments in NGN (Paystack) and USD (Stripe). |
| Document intake | DOC-1 to DOC-5 | Encrypted upload. Classify, extract, examine. Field-to-page evidence links. Working copies only. |
| Register | REG-1 to REG-5 | Asset types, evidence, verification status, identity variants, change log, reports. |
| Discovery | DIS-1 to DIS-5 | Dormant-list upload and parse. Deterministic matcher with analyst queue. Registrar letter generator and response log. Memory-prompts interview guide. Nothing auto-confirmed. |
| Title risk | TIT-1 to TIT-3 | Rules engine, Lagos pack, fee estimator, perfection plan. |
| Recovery | REC-1 to REC-3 | Recovery case board with SLA timers and outcome evidence. |
| Verification | VER-1 to VER-4 | Preparer ≠ signer enforced in DB. Checklist gate. AUP statement. Signer name, ICAN reference, timestamp. JIT full-register access. |
| Partner handoff | PAR-1, PAR-2 | Law-firm parcel packet and trustee asset schedule exports. |
| Client delivery | CX-1 | Watermarked PDF through an expiring single-recipient link, with download count and revoke. |
| Platform | — | Auth + MFA, RLS framework, audit hash chain, KMS envelope encryption, retention jobs, observability. |

## 4. Out of scope for the MVP

| Item | IDs | Phase |
|---|---|---|
| Client portal, PWA | CX-2 to CX-5 | V1 (Track C) |
| Sealed vault, trigger state machine, key shares | VLT-1 to VLT-8 | V1 |
| Parcel monitoring, regulatory watch | MON-1 to MON-4 | V1 |
| Heir access levels, executor pack | HEIR-*, EXE-* | V1 |
| Insider exposure review | INS-* | V1 |
| Will health check | WILL-1 to WILL-6 | V1 (tables in `db/migrations/0100_v1_vault_monitor_will.sql`, not applied in MVP) |
| Partner portal, referral tracking | PAR-3, PAR-4 | V1 |
| Other states than Lagos | TIT-4 | V1 |
| Case Ops and Heir Guide agents | — | V2 |
| Native mobile apps | — | Deferred |
| Automated scraping of dormant lists, registrars, e-GIS | — | Not in MVP. Analysts download and upload; results recorded as evidence. |

## 5. Console screens in scope (14)

Matches `reference/prototypes/console.html` and `reference/specs/Heirline_Design_and_Relume_Prompts.md` Part A1.

1. Sign in + MFA
2. Engagements list
3. Engagement overview
4. My tasks
5. Document intake
6. Extraction review (**most important screen**)
7. Discovery matcher queue
8. Register (scoped view)
9. Parcel detail
10. Title perfection plan
11. Recovery cases (kanban)
12. Verification and sign-off (**signature moment, most care**)
13. Reports and partner packets
14. Audit log (admin / DPO)

Roles in the console: `analyst`, `verifier`, `admin`, `dpo`. The sidebar and permissions change with the role (the prototype's "Prototype controls" switch models this).

## 6. Website pages in scope (Track B)

Home; How it works; Services overview; four service pages on one template (Land & Paper Health Check, Continuity Retainer, Heir Readiness, Estate Asset Trace); For the diaspora; For partners; Security and privacy; About; Insights listing + article template; FAQ; Contact / Book a private consultation; Privacy notice; Terms of use.

The consultation form is the only functional feature: a 4-step form, consent checkbox, server-side validation, content-free notification to the team, a confirmation screen. Submissions are personal data: store encrypted, send a content-free email, and apply the same retention rules.

## 7. Build order and gates

| Phase | Ships | Done when | TRD weeks |
|---|---|---|---|
| 0 | Monorepo, tokens, `packages/ui` base, fidelity harness, CI | Fidelity check runs against all three prototypes; CI green | 1 |
| 1 | Auth + MFA, schemas, KMS envelope encryption, audit chain, RLS framework + tests, KESTREL seed | A synthetic family can be created and every access is logged | 1–2 |
| W | Website (Track B) | Home, one service page and the consultation form match the prototype at 1440 and 390 | parallel |
| 2 | Engagements, consents, letters of authority, tasks, payments, encrypted upload | First engagement can be opened and paid in the system | 3–4 |
| 3 | AI gateway, classify, extract, examine, resolution queue, evidence items | Extraction eval meets the target on the eval set | 5–6 |
| 4 | Register, identity variants, matcher, dormant-list parsing, registrar letters | Matcher eval meets thresholds; analysts clear candidates in the console | 7–8 |
| 5 | Rules engine, Lagos pack, fee estimator, title analyst drafting, cross-document checks, perfection plan, recovery board | Golden tests pass; first real parcels scored and reviewed by the partner lawyer | 9–10 |
| 6 | Verification with JIT access, reports, packets, expiring links, retention jobs | First signed report delivered from the system end to end | 11–12 |
| 7 | Hardening: pen-test prep, runbooks, restore test, DPIA artefacts wired | Launch checklist in `docs/05_Decisions_and_Gaps.md` fully ticked | 12 |

**Concierge from day one.** Operations start in week 1 with spreadsheets and manual process. The tooling replaces manual steps as each phase ships. Do not wait for software to take the first client.

## 8. MVP exit criteria

- 10 real engagements processed in the system.
- Zero security incidents.
- DPIA, record of processing, consent texts, NDPC registration, DPO appointment and processor agreements complete.
- A written list of V1 priorities from analyst and verifier feedback.

## 9. If time slips, cut in this order

1. Automated cross-document consistency drafting prose (keep the rule-generated findings).
2. Kanban drag-and-drop polish (keep a status dropdown).
3. Registrar letter generator templates beyond the top 3 registrars.
4. Website secondary pages (keep Home, one service page, consultation form, Privacy, Terms).

**Never cut:** RLS tests, audit chain, encryption, preparer ≠ signer, fail-closed behaviour, the examiner pass, JIT access logging.
