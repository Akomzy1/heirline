# Heirline — Premium design prompts for Claude Design and Relume

**What's in this file**
- **Part A: Claude Design prompts** for the product. Prompt A1 covers the internal console (MVP). Prompt A2 covers the client, heir and executor portal (V1).
- **Part B: Relume prompt** for the marketing website (sitemap and page wireframes).

Paste each prompt as written. A1 and A2 are separate so each gets the attention it needs. Run A1 first, then A2 with "use the same design language as the console" if both live in the same Claude Design project.

---

## Shared design direction (already included in A1 and A2)

**Quality bar: highly premium.** Clients are wealthy families paying millions of naira for discretion and trust. Every screen should feel as considered as a private bank's client materials or a luxury watchmaker's catalogue. Premium here means **restraint and craft**, not decoration: the luxury is in the typography, spacing and detail.

- **Feel:** a discreet private-client house, not a tech startup. Quiet confidence, nothing shouting. No "AI" visuals, no gradients, no robots, no sparkles, no stock illustration.
- **Palette:** deep ink navy as the primary colour, warm parchment/ivory backgrounds, muted brass/gold used sparingly as a mark of significance (signatures, seals, the vault), slate greys for chrome. Status colours desaturated: sage (verified), ochre (needs attention), oxblood (high risk), slate (unscored).
- **Type:** a refined high-contrast serif for display headings, numbers on summary cards and the wordmark; a precise neo-grotesk sans for UI and tables; small caps or letter-spaced uppercase for section labels; tabular lining numerals for all figures.
- **Detail:** hairline rules (0.5–1px) instead of heavy borders or shadows; generous margins; a strict baseline grid; thin-line custom icons; a monogram "H" mark; a wax-seal or embossed motif reserved for the vault and the signed verification statement.
- **Motion (for prototypes):** slow, soft transitions (200–300ms ease-out); nothing bouncy.
- **Density:** the console is information-dense (staff use it all day) but must still feel tailored: refined tables, not a generic admin template. The client portal is spacious, calm and mobile-first.
- **Avoid:** generic SaaS dashboard look, default component-library styling, bright saturated colours, pill-shaped buttons everywhere, heavy drop shadows, emoji, stock photos, cluttered cards.
- **Privacy in the UI:** staff screens show family **code names** (e.g. "KESTREL"), never surnames. Account and title numbers are masked (•••• 4471) with a "reveal" control that is logged.
- **Data:** all placeholder data is fictional.

---

## Part A1 — Claude Design prompt: Internal console (MVP)

```
Design high-fidelity, highly premium screens for "Heirline Console", the internal web app used by the staff of Heirline, a discreet Nigerian private-client firm. Heirline builds a verified register of everything a wealthy family owns (land, shares, unclaimed dividends, dormant bank accounts, pensions, policies, private company stakes, informal loans), checks land titles, recovers forgotten money, and hands verified packs to partner law firms and trustee companies. It never writes wills or holds money.

USERS
- Analyst: works assigned tasks (document review, registrar searches, land checks).
- Verifier: an independent chartered accountant who reviews the evidence and signs the final report.
- Admin/DPO: manages users and config, reads the audit log.

DESIGN DIRECTION — PREMIUM IS NON-NEGOTIABLE
- Quality bar: as considered as a Swiss private bank's internal tools or a luxury maison's client systems. Premium means restraint and craft: typography, spacing, hairline detail. Not decoration.
- Feel: quiet confidence; a private-client house, not a tech startup. No AI imagery, no gradients, no stock illustration, no emoji.
- Palette: deep ink navy primary, warm ivory/parchment backgrounds, muted brass used sparingly for moments of significance (signatures, seals, sign-off), slate greys for chrome. Desaturated status colours: sage = verified, ochre = needs attention, oxblood = high risk, slate = unscored.
- Type: refined high-contrast serif for page titles, key figures and the "Heirline" wordmark with a monogram "H"; precise neo-grotesk sans for UI and tables; letter-spaced small caps for section labels; tabular lining numerals everywhere.
- Detail: hairline rules (0.5–1px) instead of boxes and shadows; strict grid and baseline rhythm; thin-line custom icons; generous outer margins even on dense screens.
- Layout: desktop-first. A slim, elegant left navigation (ink navy, ivory text), a quiet top bar with search and user menu, and tailored data tables with refined row height, subtle zebra or hairline separators, and well-designed filters. It must not look like a default admin template.
- Avoid: generic SaaS dashboards, default component-library styling, bright saturated colours, heavy drop shadows, pill buttons everywhere, cluttered cards.
- PRIVACY RULES VISIBLE IN THE UI: families are shown only by code name (e.g. "KESTREL", "OSPREY"), never surnames. Account numbers, title numbers and names are masked (e.g. "•••• 4471") with a small "Reveal (logged)" control. A subtle footer on every screen: "All access is logged."

SCREENS (one frame each)

1. Sign in + MFA
   Email/password, then a 6-digit authenticator code step. Small note: "Console access is restricted and logged."

2. Engagements list
   Table: family code name, product (Health Check / Estate Asset Trace / Retainer / Heir Readiness), stage (Onboarding, Intake, Discovery, Title review, Verification, Delivered), assigned analyst, verifier, due date, payment status. Filters by product and stage. "New engagement" button.

3. Engagement overview (KESTREL — Land & Paper Health Check)
   Header with code name, product, stage progress bar across the six stages. Panels: Checklist (engagement letter signed, NDPA consents captured, letters of authority: 3 of 4 signed, fee paid via Paystack), Open tasks (assignee, due), Findings summary (counts by type: gaps, risks, recoverable, exposure), Team (analysts, verifier). No asset details on this screen.

4. My tasks (analyst inbox)
   List grouped by due date: "Review extraction — Deed of Assignment (Lekki parcel 2)", "Confirm 4 dormant-account match candidates", "Log registrar response — Registrar B", "Collect charting result — Ibadan parcel". Each task shows engagement code name and the scope it unlocks (e.g. "Access: Land parcels only").

5. Document intake
   Drag-and-drop upload area. Table of uploaded documents: thumbnail, detected type (C of O, Deed of Assignment, Survey Plan, Share Certificate, Dividend Warrant, Bank Statement, RSA Statement, Policy), pages, status chips (Encrypted ✓, Classified, Extracting, Needs review, Unreadable → manual entry).

6. Extraction review (most important screen)
   Split view. Left: document page viewer with zoom and page thumbnails; highlighted regions for each field. Right: extracted fields form (holder name, file number, registered number, date, location, area, survey plan number), each with confidence bar and an examiner result chip (Match / Mismatch / Not found). Mismatch rows highlighted amber with the examiner's note. Actions per field: Accept, Edit, Mark unreadable. Footer: "Accept all matched fields" and "Send to evidence".

7. Discovery matcher queue
   Card list of match candidates. Each card: principal's identity variant (masked, e.g. "A•••••• O. Ch•••") vs source row (e.g. bank dormant-account list, May 2026, account •••• 9102), match score as a horizontal bar with threshold marker, short rationale text, signals (name tokens, address fragment, era). Buttons: Confirm match, Reject, Need more evidence. Note at top: "Nothing is confirmed automatically."

8. Register (scoped view)
   Tabs by asset class: Land, Shares & dividends, Bank accounts, Pensions & policies, Private stakes, Receivables, Offshore. Table rows with description (masked), owner of record, value band, verification status chip (Claimed → Evidenced → Verified → Disputed), evidence count. Banner explaining scope: "You are seeing: Land only (task-scoped access)."

9. Parcel detail (Lekki parcel 2)
   Left: simple map with parcel polygon outline. Right: Title summary (document hierarchy: "Unregistered deed of assignment"), charting result ("Free"), occupation status ("Unknown"), evidence list linking to documents. Risk score card: large band label "HIGH (58)", a breakdown list of rule hits (+30 Unregistered deed, +10 Occupation unknown, +18 Name mismatch on title), "Rules version NG-LA 2026.11.0". Fee estimate card: Governor's Consent range, stamp duty, registration, total range, "Fee schedule: Lagos, effective 1 May 2026". Button: "Add to perfection plan".

10. Title perfection plan
   Ranked table of parcels: rank, location (masked), risk band, value band, estimated cost range, recommended action, partner law firm, status. Short narrative block at the top drafted for analyst editing.

11. Recovery cases (kanban)
   Columns: Identified, Letter sent, Awaiting response, Claim filed, Recovered, Closed. Cards: type (Unclaimed dividend / Dormant balance / Share mandate / Title), owner party (Heirline, Law firm, Registrar, Bank), SLA timer, value band.

12. Verification and sign-off (verifier)
   Top banner in brass: "Full-register access open — 3h 42m remaining. Reason: Sign-off for KESTREL. All views logged." Left: checklist per asset class with progress. Centre: full register summary and findings. Right: statement preview ("Agreed-upon procedures: what was checked and what was found"), verifier name and ICAN number field, "Sign statement" button disabled until checklist complete. Note: "Preparer and signer must be different people."

13. Reports and partner packets
   List of generated outputs: Client report, Law-firm parcel packet, Trustee asset schedule. Each with recipient, watermark preview, link expiry (7 days), downloads count, "Revoke link".

14. Audit log (admin/DPO)
   Filterable table: timestamp, actor, role, action (Viewed field, Revealed masked value, Opened full-register access, Generated report), object, code name, reason. Integrity indicator: "Audit chain verified ✓".

DELIVERABLE
Produce each screen as its own frame at desktop width (1440px), consistent components across frames (sidebar, tables, status chips, banners), with realistic fictional Nigerian placeholder data (locations such as Lekki Phase 1, Ibadan, Abuja, Ijebu-Ode; naira amounts as ranges). Give the sign-off screen (12) the most care: the verifier's signature moment should feel ceremonial, with a brass seal motif on the signed statement. Before finishing, review every frame against the premium bar above and refine anything that looks like a default template.
```

---

## Part A2 — Claude Design prompt: Client, heir and executor portal (V1)

```
Design high-fidelity, highly premium screens for the "Heirline" client portal: the private, mobile-first web app used by wealthy Nigerian families (at home and in the diaspora) whose assets Heirline has verified. These clients use the private-banking apps of top global banks and expect at least that standard. Use the same design language as the Heirline Console if it exists in this project.

DESIGN DIRECTION — PREMIUM IS NON-NEGOTIABLE
- Quality bar: the client area of a top private bank or a luxury maison's client app. Premium means restraint and craft: exquisite typography, generous space, hairline detail. Not decoration.
- Palette: deep ink navy, warm ivory/parchment, muted brass used sparingly for moments of significance (the vault, seals, key holders); desaturated status colours (sage verified, ochre attention, oxblood high risk).
- Type: refined high-contrast serif for headings, key figures and the "Heirline" wordmark with a monogram "H"; precise neo-grotesk sans for body; letter-spaced small caps for labels; tabular lining numerals.
- Detail: hairline rules, no heavy shadows, thin-line custom icons, large touch targets, calm vertical rhythm. The vault screens should feel like a private safe-deposit room: a wax-seal or embossed motif, deliberate and quiet.
- Mobile-first frames at 390px wide; also show the Home screen at 1440px desktop.
- No AI imagery, no marketing tone, no stock photos, no emoji, no bright colours, no generic fintech look. Plain, respectful, unhurried language.
- Notifications are deliberately content-free ("You have an update in your Heirline portal"), so the portal is where details are shown.

USERS
- Principal: the asset owner (e.g. a 65-year-old business owner).
- Heir: an adult child who sees only what the principal allows.
- Executor: the person handling the estate after a confirmed death.

SCREENS (one frame each)

1. Sign in
   Passkey or magic link + one-time code. Calm reassurance line: "Your family register is encrypted. Only you and those you choose can open it."

2. Principal home
   Greeting. Four summary cards: Assets verified (e.g. 23), Items needing attention (3), Money identified for recovery (₦ range), Land watch (5 plots monitored, last checked date). Below: "Recent updates" list and "Your next annual review" date. Desktop version of this screen as well.

3. My register
   Asset classes as tappable rows with counts and status: Land, Shares & dividends, Bank accounts, Pensions & policies, Business interests, Money owed to me, Assets abroad. Drill-in to a Land list with location, title status chip, risk band.

4. Land plot detail
   Small map, title status in plain words ("Your deed is not yet registered. This puts the plot at higher risk."), what's being done ("Your lawyer is applying for Governor's Consent — step 2 of 4"), estimated cost range, documents held (and where the originals are kept).

5. Land watch alert
   Alert screen: "Possible activity detected on your Ibadan plot." Before/after satellite thumbnails side by side, date, status: "A surveyor will visit within 7 days to confirm." Buttons: "I know about this" / "I don't recognise this".

6. Recovery tracker
   List of recovery items with simple progress steps: "Unclaimed dividends — Registrar B: claim filed", "Dormant account — Bank C: awaiting bank response", amounts as ranges.

7. Family vault
   Status card: "Sealed — version 4, updated 12 Oct 2026". Key holders section: You, Your lawyer (firm name), Heirline — with a short plain explanation: "Two of these three keys are needed to open your vault. Heirline cannot open it alone." Buttons: "Update vault", "Recovery sheet".

8. Who sees what (release map and heir levels)
   List of family members with a level selector: "Nothing yet", "Knows a plan exists + who to call", "Sees categories of assets (no values or locations)", "Sees everything (only after release)". Separate row for Executor: "Receives the executor pack on release".

9. Heir view (level: categories only)
   Welcome message from the principal (optional text). Shows asset categories without values or locations, "Who to contact" card (family lawyer, Heirline), and a short learning section: "How land titles work", "What happens in probate".

10. Executor — release in progress
   Timeline of the release process: Death reported → Documents checked → Lawyer confirmed → Waiting period (day 9 of 14) → Release. Plain explanation of why there is a waiting period. Contact card.

11. Executor day-one pack
   After release: sections for Asset schedule, Where the originals are, Who to call (lawyer, trustee, Heirline), Claims to make (registrars, banks) with status, Probate checklist with tick boxes. Download as PDF (watermarked).

DELIVERABLE
Each screen as its own mobile frame (390px) plus the desktop Home (1440px), consistent components, fictional Nigerian placeholder data (Lekki Phase 1, Ibadan, Abuja, Ijebu-Ode; naira as ranges; masked references like "•••• 4471"). Give the Family vault (7) and Executor release (10) screens the most care: they are the emotional core of the product and must feel secure, dignified and calm. Before finishing, review every frame against the premium bar above and refine anything that looks like a generic fintech app.
```

---

## Part B — Relume prompt: Marketing website

Paste the long version into Relume's site builder. If Relume truncates the input, use the short version.

**Note on premium:** Relume's wireframes are structural, so the premium feel comes later, in the style guide and visual design. Use Relume for the sitemap and page structure, then apply the same premium direction as Part A (ink navy, ivory, sparing brass; high-contrast serif headlines; hairline detail) when styling, whether in Relume's style guide, Figma or Claude Design. When choosing among Relume's section layouts, prefer editorial, spacious layouts over dense feature grids, icon-card rows and testimonial carousels.

### B1. Long version

```
Heirline is a discreet private-client firm in Nigeria that builds a verified register of everything a wealthy family owns, keeps it current, and keeps it ready for the day the family needs it. It serves Nigerian high-net-worth families at home and in the diaspora (UK, US, UAE), especially land-heavy families whose wealth is spread across Lagos, Abuja, hometowns and abroad.

The problem: wealth in Nigeria is often scattered and under-documented. Land titles are incomplete, old shares and dividends are forgotten, dormant bank balances move into government-held funds, and often only the head of the family knows the full picture. When they die or lose capacity, families cannot find everything, land is encroached, probate stalls and relatives end up in court.

What Heirline does:
1. Land & Paper Health Check: a fixed-fee audit that finds and verifies assets, scores the risk on each land title, prioritises which titles to fix first, and identifies money that can be recovered. Findings are signed off by an independent chartered accountant.
2. Continuity Retainer: the register is refreshed every year, land is watched by satellite for encroachment, regulatory changes are tracked, and the family runs an annual "if I died tomorrow" review.
3. Sealed family vault: the register is encrypted and can only be opened by two of three key holders (the client, their lawyer, Heirline) after a confirmed death or incapacity. Heirline can never open it alone.
4. Heir Readiness: prepares adult children at the pace the parent chooses, with staged disclosure, family briefings and site visits.
5. Estate Asset Trace: for families already in probate, a fast, verified trace of what the deceased owned.

What Heirline does not do: write wills, hold money, act as trustee or give investment advice. It works alongside the family's lawyers, trustee companies and private bankers, who act on its verified findings.

Audiences: principals (business owners, senior professionals, 50+), diaspora Nigerians with assets at home, executors of estates, and partners (law firms, trustee companies, private banks, surveyors).

Positioning and tone: a highly premium, discreet private-client house, on the level of a Swiss private bank, a top family office or a heritage law firm. Quiet confidence, editorial and unhurried. Generous whitespace, few words per section, large refined serif headlines, long-form editorial layouts rather than busy feature grids. No hype, no "AI" positioning, no stock images of handshakes, no countdowns or pop-ups. Imagery, where used: architectural details, paper, ink, land and light, never people in suits shaking hands. Primary call to action everywhere: "Book a private consultation". No public pricing.

Pages needed: Home; How it works; Services (with sub-pages for Land & Paper Health Check, Continuity Retainer, Heir Readiness, Estate Asset Trace); For the diaspora; For partners (law firms, trustees, private banks); Security and privacy (encryption, sealed vault, data protection compliance, what staff can and cannot see); About (independence, advisory board, our approach); Insights (articles on land titles, unclaimed dividends, probate, succession); FAQ; Contact / Book a private consultation (with a short confidential enquiry form and a promise of discretion).
```

### B2. Short version

```
Heirline is a discreet Nigerian private-client firm. It finds, verifies and safely records everything a wealthy family owns (land, shares, unclaimed dividends, dormant accounts, business stakes, assets abroad), checks land titles, recovers forgotten money, watches land for encroachment, and keeps the register in a sealed vault that opens only after a confirmed death or incapacity. Findings are signed off by an independent chartered accountant. Heirline does not write wills or hold money; it works with the family's lawyers and trustees. Audiences: Nigerian high-net-worth families, diaspora Nigerians, executors, and partner law firms, trustees and private banks. Highly premium private-client brand, like a Swiss private bank or heritage law firm: quiet, editorial, generous whitespace, few words, no hype, no AI positioning, no stock handshakes. CTA: "Book a private consultation"; no public pricing. Pages: Home, How it works, Services (Land & Paper Health Check, Continuity Retainer, Heir Readiness, Estate Asset Trace), For the diaspora, For partners, Security and privacy, About, Insights, FAQ, Contact.
```

### B3. Copy guardrails for the generated site

When Relume drafts copy, edit it against these rules before publishing:
- **No guarantees** of recovery amounts, title outcomes or timelines.
- **No legal-service claims.** Say "our partner law firms" for titles, probate and wills (the Legal Practitioners Act reserves these to lawyers).
- **Statistics only with a source**, e.g. SEC figures on unclaimed dividends (₦200bn–₦270bn range, 2025–2026). Avoid the unsourced "70% of Nigerians die without a will".
- **No client names, photos or testimonials** until clients give written consent.
- **Advisory board names** only with each adviser's written consent.
- **Security claims** must match what is actually built (sealed vault is a V1 feature; mark it "coming soon" if the site launches before it ships).
