# Heirline — Prototype prompts for Claude Design

Run these in the same Claude Design project that holds the wireframes and the Heirline design system. Run them in order: **P0 → P1 → P2 → P3**. P0 sets up shared demo data so all three prototypes tell the same story.

| Prompt | Builds | Main use |
|---|---|---|
| P0 | Shared demo dataset (the fictional KESTREL family) | Consistency across prototypes |
| P1 | Staff console prototype | Showing partners and the verifier how the work is done |
| P2 | Client, heir and executor portal prototype | Client and investor demos |
| P3 | Marketing website prototype | Brand and partner conversations |

---

## P0 — Shared demo data

```
Before building any prototype, set up one shared fictional dataset for all Heirline prototypes in this project, and use it consistently everywhere. All data is fictional.

FAMILY: code name KESTREL (staff screens show only the code name; client screens show the principal as "Chief A." and family members by first name only).
- Principal: Chief A., 67, business owner, lives in Lagos.
- Spouse: Mrs F.
- Heirs: Tolu (eldest son, lives in London, level "Categories only"), Kemi (daughter, lives in Lagos, level "Plan exists + who to call"), Dayo (youngest son, level "Nothing yet").
- Executor: Tolu.
- Family lawyer: "Adeyemi & Co." (fictional partner law firm). Trustee: "Crestfield Trustees" (fictional).

ASSETS (23 verified, 3 need attention):
- Land (5 plots): Lekki Phase 1 (registered C of O, LOW risk); Lekki parcel 2 (unregistered deed of assignment, name mismatch, HIGH risk, score 58); Ibadan, Akobo (survey plan only, MODERATE, encroachment alert open); Abuja, Lokogoma (Governor's Consent, LOW); Ijebu-Ode family land (family conveyance only, CRITICAL, unscored until charting returns).
- Shares: holdings with "Registrar A" and "Registrar B" from the 2000s; ₦18m–₦26m in unclaimed dividends identified.
- Bank accounts: 4 active, 1 dormant at "Bank C" (match confirmed, claim in progress).
- Pension: 1 RSA. Policies: 2 life policies.
- Business interests: 40% stake in a private distribution company.
- Money owed: a ₦35m loan to a relative (documented by a signed note).
- Abroad: a London flat (catalogued; UK counsel coordinates).

ENGAGEMENT: Land & Paper Health Check, currently at "Verification" stage. Analyst: Bisi. Verifier: O. Akomolede, ICAN (show ICAN number as "ICAN •••• 3318").

OTHER ENGAGEMENTS (for list views): OSPREY (Estate Asset Trace, Discovery), HERON (Continuity Retainer, Delivered), MERLIN (Health Check, Intake), PLOVER (Heir Readiness, Onboarding).

DATES: today is 9 November 2026. Vault sealed 12 October 2026, version 4. Land watch last checked 7 November 2026.

Masked references always look like "•••• 4471". Naira amounts are shown as ranges.
```

---

## P1 — Staff console prototype

```
Build a high-fidelity, interactive, clickable prototype of the Heirline Console using ONLY the Heirline design system (Evening sidebar, Day content, Compact density) and the shared KESTREL dataset. It must feel highly premium: a private bank's internal tool, crafted and calm, never a generic admin template. Use the design system's motion tokens (200–300ms ease-out; the 600ms reveal only for the seal).

PROTOTYPE CONVENTIONS
- Desktop 1440px. All navigation in the sidebar works.
- A discreet "Prototype controls" button in the bottom-right corner (visible only in the prototype) lets the presenter switch role: Analyst (Bisi) / Verifier (O. Akomolede) / Admin. The sidebar and permissions change with the role.
- Include realistic loading (skeleton rows), empty and error states where the flows below touch them.
- Every reveal of a masked value, and every opening of full-register access, adds a row to the Audit log in real time.

FLOWS TO MAKE CLICKABLE

Flow 1 — Sign in
Sign-in → 6-digit authenticator code (any 6 digits work) → Engagements list.

Flow 2 — Analyst works an extraction (role: Analyst)
My tasks → "Review extraction — Deed of Assignment (Lekki parcel 2)" → Extraction review split view. Clicking a field highlights its region on the document. One field shows a Mismatch (holder name). The analyst clicks Edit, corrects it, clicks Accept; the chip turns to Match. "Accept all matched fields" → "Send to evidence" → calm toast "Fields saved to evidence." → task disappears from My tasks.

Flow 3 — Discovery matcher (role: Analyst)
Matcher queue with 4 candidates. Confirm one (Bank C dormant account) → card collapses with "Confirmed" state and a new recovery case appears in Recovery cases. Reject one. Mark one "Need more evidence" (creates a task). Header counter updates.

Flow 4 — Masked value reveal
On the Register (Land tab, scoped banner visible), click "Reveal (logged)" on a title number → value shows with a small 30-second timer and "logged" note, then re-masks. Audit log gains a row.

Flow 5 — Title review and plan
Parcel detail (Lekki parcel 2): risk card shows HIGH (58) with rule-hit breakdown and rules version; fee estimate card shows ranges with the fee-schedule date. "Add to perfection plan" → Perfection plan page with the parcel ranked #1 and the narrative block editable inline.

Flow 6 — Recovery board
Recovery cases kanban: drag the Registrar B unclaimed-dividend card from "Letter sent" to "Awaiting response"; SLA timer resets.

Flow 7 — Verification and sign-off (role: Verifier) — the signature moment, build with the most care
Engagement KESTREL → "Begin sign-off" → re-authentication modal (code + typed reason "Sign-off for KESTREL") → brass Just-in-time access banner appears with a live countdown from 4h 00m and "All views logged".
Checklist by asset class: the presenter ticks the remaining items; progress fills. "Sign statement" (Ceremonial brass button) is disabled with the note "Preparer and signer must be different people ✓ · Checklist incomplete" until all items are ticked.
On sign: a confirmation dialog shows the statement summary → confirm → the brass seal settles onto the statement with the slow 600ms reveal, the signature line fills with the verifier's name, ICAN reference and timestamp. Stage bar moves to "Delivered". Toast: "Statement signed. Report ready."

Flow 8 — Report delivery
Reports and packets → client report row → "Create secure link" → link card with recipient, 7-day expiry and download count 0 → "Revoke link" changes state to Revoked. Watermark preview shows recipient and timestamp.

Flow 9 — Audit log (role: Admin)
Filter by KESTREL → the rows created during this demo appear at the top. "Audit chain verified ✓" indicator.

Finish by reviewing every screen against the design system and the premium bar, and fix anything that looks like a default template.
```

---

## P2 — Client, heir and executor portal prototype

```
Build a high-fidelity, interactive, clickable prototype of the Heirline client portal using ONLY the Heirline design system (Day theme, Comfortable density; Evening theme for the vault screens) and the shared KESTREL dataset. Mobile-first at 390px inside a phone frame, plus the Home screen at 1440px desktop. It must feel like the client area of the world's best private bank: exquisite typography, generous space, calm and dignified. Use the design system's motion tokens.

PROTOTYPE CONVENTIONS
- A discreet "Prototype controls" button lets the presenter switch persona (Chief A. / Tolu as heir / Tolu as executor) and vault state (Sealed / Cooling-off day 9 of 14 / Released).
- Bottom navigation: Home, Register, Alerts, Vault, More.
- Notifications are content-free; show one as a lock-screen style banner: "You have an update in your Heirline portal."

FLOWS TO MAKE CLICKABLE

Flow 1 — Sign in
Passkey prompt (one tap) → Home. Reassurance line under the sign-in: "Your family register is encrypted. Only you and those you choose can open it."

Flow 2 — Home and register (Chief A.)
Home summary cards (23 verified, 3 need attention, ₦18m–₦26m identified for recovery, 5 plots watched) with display-serif figures. Tap "Register" → asset classes → Land → Lekki parcel 2 detail: plain-language title status, "Your lawyer is applying for Governor's Consent — step 2 of 4", cost range, where the originals are kept.

Flow 3 — Land watch alert
Tap the content-free notification → Alert: "Possible activity detected on your Ibadan plot." Before/after satellite comparison with a draggable divider. Tap "I don't recognise this" → bottom sheet confirming "A surveyor will visit within 7 days. Your lawyer has been informed." → alert status updates to "Field visit scheduled".

Flow 4 — Recovery tracker
List of recovery items with step progress; tap the Bank C dormant account to see its timeline.

Flow 5 — Family vault (Evening theme) — build with the most care
Vault screen: sealed state with the brass seal, "Sealed — version 4, updated 12 Oct 2026". Key-holder diagram: You, Adeyemi & Co., Heirline, with the line "Two of these three keys are needed to open your vault. Heirline cannot open it alone." Tap "Who sees what" → family list with level selectors. Change Kemi from "Plan exists + who to call" to "Categories only" → confirmation sheet explaining exactly what Kemi will now see → confirm with passkey → the vault re-seals as version 5 with the slow seal animation.

Flow 6 — Heir view (switch persona to Tolu as heir)
Optional welcome note from Chief A.; asset categories without values or locations; "Who to contact" card; two short learning cards ("How land titles work", "What happens in probate").

Flow 7 — Executor release (switch persona to Tolu as executor)
Vault state "Cooling-off, day 9 of 14": vertical timeline Death reported ✓ → Documents checked ✓ → Lawyer confirmed ✓ → Waiting period (9 of 14) → Release, with a calm explanation of why the waiting period exists. Switch vault state to Released → the seal opens with the slow reveal → Executor day-one pack: Asset schedule, Where the originals are, Who to call, Claims to make (with status), Probate checklist the executor can tick. "Download PDF (watermarked)" shows a confirmation.

Flow 8 — Desktop Home
The Home screen at 1440px for Chief A., same content, editorial two-column layout.

Use respectful, unhurried copy throughout. Finish by reviewing every screen against the design system and the premium bar; refine anything that looks like a generic fintech app.
```

---

## P3 — Marketing website prototype

```
Build a high-fidelity, interactive, responsive prototype of the Heirline marketing website from the Relume sitemap and wireframes in this project, using ONLY the Heirline design system (Day theme, Comfortable density, editorial layouts). It must feel like a highly premium private-client house on the level of a Swiss private bank or a heritage law firm: few words, large refined serif headlines, generous whitespace, unhurried.

PAGES: Home; How it works; Services overview; Land & Paper Health Check; Continuity Retainer; Heir Readiness; Estate Asset Trace (the four service pages share one template: who it's for, what you receive, how it works, the cost of doing nothing, private consultation CTA); For the diaspora; For partners; Security and privacy; About (independence, approach, advisory board placeholders marked "to be announced"); Insights listing and one article template; FAQ; Contact / Book a private consultation; Privacy notice; Terms of use.

HOME — keep to 7–8 sections:
1. Hero: "Everything your family owns. Verified, protected, ready." with a quiet sub-line and "Book a private consultation".
2. The problem, told calmly (scattered assets, incomplete titles, forgotten dividends, families left searching).
3. What Heirline does (find, verify, protect, prepare).
4. How it works (four steps).
5. Independence and security (independent chartered-accountant sign-off; sealed vault that Heirline cannot open alone; partner law firms do the legal work).
6. Services overview (four services).
7. An Insights teaser.
8. Closing private consultation CTA.
No testimonial sections, no logo strips, no statistics without a source, no pricing.

INTERACTIONS
- Sticky header that becomes a slim ivory bar on scroll; refined full-screen mobile menu.
- Subtle scroll reveals (opacity + small translate, 300ms), respecting reduced motion.
- "Book a private consultation" opens a calm multi-step form: (1) who you are (principal, family member, executor, adviser), (2) what you'd like help with, (3) preferred contact method and time, (4) consent checkbox linking to the Privacy notice. Submit → confirmation: "Thank you. A member of our team will contact you discreetly within one working day."
- FAQ accordion; Insights cards linking to the article template.
- Show desktop (1440px) and mobile (390px) for Home, one service page and the consultation form.

IMAGERY: architectural details, paper, ink, light on surfaces, aerial land textures, archival documents. Warm and desaturated. Never handshakes or people in suits.

COPY RULES: no guarantees of outcomes, amounts or timelines; legal work is always "our partner law firms"; calm, precise, respectful language; no exclamation marks.

Finish by reviewing every page against the design system and the premium bar; refine anything that reads like a SaaS landing page.
```

---

## Acceptance checklist (review each prototype before sharing)

- [ ] Uses only design-system tokens and components; nothing looks like a default template.
- [ ] KESTREL data is consistent across console, portal and website examples.
- [ ] Staff screens never show a surname; references are masked.
- [ ] Signature moment (console) and vault/release (portal) feel ceremonial but calm.
- [ ] Brass appears only at moments of significance.
- [ ] Mobile frames have 44px touch targets and readable body text (15px+).
- [ ] No testimonials, logos, pricing or unsourced statistics on the website.
- [ ] All copy is calm and contains no guarantees.

## Suggested demo order (10 minutes, for partners or investors)

1. Website Home → Book a private consultation (1 min).
2. Console: extraction review → matcher → parcel risk (3 min).
3. Console: verifier sign-off with the seal (2 min).
4. Portal: Home → land watch alert (2 min).
5. Portal: vault and "who sees what" → executor release and day-one pack (2 min).
