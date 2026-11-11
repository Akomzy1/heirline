# 02 — User flows

Each flow lists: actor, steps, states, **failure paths (fail closed)**, audit events, and requirement IDs. Flow numbers F1–F9 for the console follow the prototype's flows (P1 Flow 1–9) so you can click the prototype and read the flow side by side. F0 and F10 are added here.

Stages of an engagement (the stage bar in the console): **Onboarding → Intake → Discovery → Title review → Verification → Delivered.**

---

## Console flows (MVP)

### F0 — Open an engagement (Onboarding)  · ENG-1…ENG-6
**Actor:** admin or analyst (lead).
1. "New engagement" → choose product (Health Check / Estate Asset Trace / Retainer / Heir Readiness), create or select a family. System generates a random `code_name` (e.g. KESTREL). Surname is never entered outside `identity`.
2. Set scope (≤5 parcels plus listed shares, accounts, RSA, policies for a Health Check), fee, currency, analysts, verifier.
3. Generate the **engagement letter** (non-custodial scope, no legal or investment advice, AUP framing, limitation of liability). Send by expiring link. E-sign or in-app OTP click-sign (**[DECIDE]**, behind an interface).
4. Capture **NDPA consent per data category**, each with `text_version`, timestamp and method. No sensitive data is collected before consent exists.
5. Collect **letters of authority** (registrar, bank, land registry) with validity dates.
6. **Verify the principal's identity** (KYC provider **[DECIDE]**). Store the result and a salted hash, never the raw NIN.
7. Take payment: Paystack (NGN) or Stripe (USD), split payments for audit plus retainer. Webhooks are signature-verified and idempotent.
8. Checklist on the Engagement overview turns complete; stage moves to **Intake**.

**Fail closed:** document upload and task creation stay disabled until consent, identity and payment checks are complete. Withdrawn consent halts tasks that depend on that category.
**Audit:** `engagement.created`, `consent.granted`, `consent.withdrawn`, `loa.signed`, `kyc.completed`, `payment.received`.

### F1 — Sign in  · Platform
Email + password → 6-digit authenticator code (or passkey) → Engagements list. Session 8 hours. Note on screen: "Every view of a family's record is logged and reviewed by our data protection officer." and "Access to this console is recorded."
**Fail closed:** no MFA enrolled = cannot reach any screen. Disallowed country (if allowlist enabled) = blocked and logged. Five failed codes = lockout and alert.
**Audit:** `auth.signin`, `auth.mfa_failed`, `auth.lockout`.

### F2 — Analyst works an extraction  · DOC-1…DOC-5
**Actor:** analyst. Scope shown on the task: "Access: Land parcels only".
1. Upload scans/photos on **Document intake**. File is encrypted server-side before storage; the row shows **Encrypted ✓**.
2. Job: **Classify** (Haiku, page 1 downscaled) → `doc_class` + confidence. Unreadable → manual-entry task.
3. Job: **Extract** (Sonnet, page images only, no family context) → class-specific JSON with per-field confidence.
4. Job: **Examine** (Sonnet; Opus for high-value or conflicting) with page images + extracted fields only → per-field `match | mismatch | not_found`.
5. My tasks → "Review extraction — Deed of Assignment (Lekki parcel 2)" → **Extraction review** split view. Clicking a field highlights its region on the page.
6. Per field: **Accept**, **Edit**, **Mark unreadable**. A mismatch (e.g. holder name) shows amber with the examiner's note. Edit → correct → Accept → chip turns **Match**.
7. "Accept all matched fields" → "Send to evidence" → toast "Fields saved to evidence." → task leaves My tasks.

**Rule:** a field reaches `evidence_items` only if the examiner returned `match` **and** confidence ≥ the `match_thresholds` value, **or** an analyst resolved it (recorded as `resolved_by`).
**Fail closed:** invalid model JSON is retried once, then goes to the human queue. Examiner `unreadable` → manual entry.
**Audit:** `document.uploaded`, `extraction.created`, `examination.created`, `evidence.resolved`, `field.viewed`.

### F3 — Discovery matcher  · DIS-1…DIS-5
**Actor:** analyst.
1. Analyst downloads a bank's dormant-account list or receives a registrar response and **uploads** it. A job parses it into rows. No scraping in MVP.
2. Matcher (deterministic): normalise names (case, diacritics, titles, compound names) → generate variants (token reorder, initials, maiden/married names, aliases, transliterations) → score with Jaro-Winkler on tokens + token-set overlap + secondary signals (address fragment, institution, era).
3. Above `auto_review` → queue. Below `discard` → dropped. **Nothing is auto-confirmed.** Banner: "Nothing is confirmed automatically."
4. Each card: masked identity variant vs masked source row, score bar with threshold marker, rationale (LLM-written, never sets the score), signals.
5. Actions: **Confirm match** → card collapses to "Confirmed" and a **recovery case** is created. **Reject** → dropped with reason. **Need more evidence** → creates a task. Header counter updates.

**Audit:** `match.confirmed`, `match.rejected`, `match.needs_evidence`, `recovery_case.created`.

### F4 — Reveal a masked value  · SEC controls
On the **Register** (scoped banner visible: "You are seeing: Land only (task-scoped access)."), click **Reveal (logged)** on a title number → value shows with a 30-second timer and a small "logged" note → re-masks.
**Fail closed:** reveal is refused if the task grant does not cover the asset type.
**Audit:** `field.revealed` (actor, object, code name, reason).

### F5 — Title review and perfection plan  · TIT-1…TIT-3
1. **Title analyst** (Sonnet) reads the parcel's *resolved* evidence and produces the typed `ParcelEvidence` object (document hierarchy, name match, charting result, gazette status, encumbrances, occupation).
2. **Rules engine** (pure TS) returns `{score, band, hits[], missing_evidence[], fee_estimate}` with `rule_version` and config sha256.
3. **Parcel detail** shows the map outline, title summary, evidence links, **risk card** (e.g. "HIGH (58)", hit breakdown, "Rules version NG-LA 2026.11.0") and **fee estimate card** (ranges, "Fee schedule: Lagos, effective 1 May 2026").
4. "Add to perfection plan" → **Perfection plan**: parcels ranked by `risk_weight × value_band_weight ÷ cost_band_weight`; narrative block drafted by Sonnet from score + hits + fee estimate; analyst edits inline; verifier approves.

**Fail closed:** missing required inputs (`document_hierarchy`, `charting_result`) = band **unscored** and a `collect_evidence` task. Example: Ijebu-Ode shows unscored until charting returns.
**Config change:** a new rule/fee version triggers a **re-score diff** for analyst review. It never silently changes a stored score.
**Audit:** `parcel.scored`, `plan.item_added`, `plan.narrative_edited`.

### F6 — Recovery board  · REC-1…REC-3
Kanban columns: **Identified → Letter sent → Awaiting response → Claim filed → Recovered → Closed**. Card = type (Unclaimed dividend / Dormant balance / Share mandate / Title), owner party (Heirline / Law firm / Registrar / Bank), SLA timer, value band. Dragging a card to the next column resets the SLA timer. Moving to **Recovered** requires an outcome value and an evidence item.
**Audit:** `recovery_case.moved`.

### F7 — Verification and sign-off  · VER-1…VER-4  (**signature moment**)
**Actor:** verifier (never the preparer).
1. Engagement KESTREL → **Begin sign-off** → re-auth modal (MFA code + typed reason, e.g. "Sign-off for KESTREL").
2. A **brass JIT banner** appears: "Full-register access open — 4h 00m remaining. Reason: Sign-off for KESTREL. All views logged." Owner/admin gets a content-free alert: "JIT access opened on engagement X."
3. Checklist by asset class. Progress fills as items are ticked. The **Sign statement** (ceremonial brass) button is disabled with: "Preparer and signer must be different people ✓ · Checklist incomplete" until every item is ticked.
4. On sign: confirmation dialog with the statement summary → confirm → the **brass seal settles onto the statement** with the slow 600 ms reveal; the signature line fills with the verifier's name, ICAN reference and timestamp. Stage → **Delivered**. Toast: "Statement signed. Report ready."
5. Statement text is versioned; the report PDF records the statement template version.

**Fail closed:** `preparer_id <> verifier_id` is a DB constraint. Report cannot be issued with any open checklist item. JIT session expiry mid-sign closes access; signing requires a fresh re-auth. No standing full-register access exists anywhere.
**Audit:** `jit.opened`, `jit.expired`, `register.viewed` (each sensitive view), `statement.signed`.

### F8 — Report and packet delivery  · REG-5, PAR-1, PAR-2, CX-1
**Reports and packets** lists: Client report, Law-firm parcel packet, Trustee asset schedule. For a row: **Create secure link** → card with recipient, **7-day expiry**, downloads 0 → **Revoke link** sets state to Revoked. Every PDF is watermarked with recipient, engagement code and issue timestamp (preview shown). Links are single-recipient with the download count logged. **No PDF is ever attached to email or WhatsApp.** Partner packets contain only the assets in scope.
**Audit:** `report.generated`, `link.created`, `link.downloaded`, `link.revoked`.

### F9 — Audit log  · Platform
**Actor:** admin or DPO (read-only). Filter by code name, actor, action, date. Newest first. Indicator: **"Audit chain verified ✓"** (weekly integrity job plus on-demand check). A chain break raises an alert.
Actions shown: Viewed field, Revealed masked value, Opened full-register access, Generated report, and the rest of the event list above.

### F10 — Website consultation form  · Track B
Four parts, set on one page as a letter (website v2): (1) who you are (principal, family member, executor, adviser), (2) what you'd like help with (topic chips, pre-filled from the categories the visitor marked on the Home page, editable), (3) preferred contact method and time, (4) consent checkbox linking to the Privacy notice (required). Submit → "Thank you. A member of our team will contact you discreetly within one working day."
Server-side validation, encrypted storage, rate limiting, honeypot. Team notification is content-free. No asset details are requested.

---

## Portal flows (V1, Track C) — summary

Spec: `reference/prototypes/portal.html`. Day theme, Comfortable density; **Evening theme for vault screens**. Mobile-first 390px, desktop Home at 1440px. Bottom nav: Home, Register, Alerts, Vault, More. Notifications are content-free: "You have an update in your Heirline portal."

| Flow | Steps |
|---|---|
| P1 Sign in | Passkey (one tap) → Home. Line: "Your family register is encrypted. Only you and those you choose can open it." |
| P2 Home and register | Four cards (23 verified, 3 need attention, ₦18m–₦26m identified for recovery, 5 plots watched). Register → asset class → Land → plot detail with plain-language title status, "Your lawyer is applying for Governor's Consent — step 2 of 4", cost range, where the originals are. |
| P3 Land watch alert | Content-free notification → alert → before/after satellite compare (draggable divider) → "I don't recognise this" → sheet "A surveyor will visit within 7 days. Your lawyer has been informed." → status "Field visit scheduled". |
| P4 Recovery tracker | Items with step progress; tap an item for its timeline. |
| P5 Family vault | Sealed card (brass seal, "Sealed — version 4, updated 12 Oct 2026"). Key-holder diagram: You, your lawyer, Heirline. "Two of these three keys are needed to open your vault. Heirline cannot open it alone." **Who sees what** with level selectors; changing a level shows exactly what the heir will now see, confirms with a passkey, and re-seals as the next version with the slow seal animation. |
| P6 Heir view | Optional welcome note, asset categories without values or locations, "Who to contact", two learning cards. |
| P7 Executor release | Timeline: Death reported → Documents checked → Lawyer confirmed → Waiting period (day 9 of 14) → Release. Calm explanation of why the waiting period exists. On release the seal opens; **day-one pack**: asset schedule, where the originals are, who to call, claims to make (with status), probate checklist, watermarked PDF. |
| P8 Desktop Home | Same content, editorial two-column layout at 1440px. |

### Disclosure levels (HEIR-1)
**L0** nothing · **L1** a plan exists + who to call · **L2** asset categories, no values or locations · **L3** full register (normally only on release). UI wording: "Nothing yet", "Knows a plan exists + who to call", "Sees categories of assets (no values or locations)", "Sees everything (only after release)".

### Vault trigger state machine (TRD §8.4)
```
SEALED
  └─ report death/incapacity → TRIGGER_REPORTED
       └─ death cert / medical attestations uploaded → ATTESTATIONS_PENDING
            └─ lawyer attestation recorded, docs examined → COOLING_OFF (default 14 days; notices to principal's channels)
                 ├─ principal responds / any objection / doc check fails → HALTED → human review (two-person)
                 └─ timer ends, no objection, all checks pass → RELEASE_APPROVED
                      └─ executor + lawyer share combine → RELEASED (scoped by release map)
```
Any state can move to `HALTED`; resuming needs two-person human review. Incapacity needs two medical attestations plus a lawyer attestation. Implemented as a pure, table-driven state machine with exhaustive tests. V2 adds `LOCKED_DURESS`.

### Will health check (V1, WILL-1…WILL-6)
Annual task to the partner law firm via a scoped packet. Heirline stores the **checklist outcome and the law firm's attestation, never the will's contents**. Gaps become findings. Portal shows "Will last checked by your lawyer: 12 Oct 2026 — no issues". Heirline never drafts or opines on a will.
