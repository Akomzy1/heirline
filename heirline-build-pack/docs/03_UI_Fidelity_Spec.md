# 03 — UI fidelity spec

**Goal:** the built product is visually indistinguishable from the approved prototypes. This document tells you how to read them, what to extract, what to correct, and how to prove fidelity.

## 1. Source of truth

| Surface | File | Viewports |
|---|---|---|
| Console | `reference/prototypes/console.html` | 1440 desktop |
| Portal | `reference/prototypes/portal.html` | 390 mobile (in phone frame), 1440 desktop Home |
| Website | `reference/prototypes/website/` (v2, approved 11 Nov 2026): `index.html`, `health-check.html`, `consultation.html`. Serve it over HTTP (e.g. `npx serve reference/prototypes/website`); read its `PROTOTYPE_NOTES.md` first | 1440 desktop, 390 mobile |

The console and portal files are self-contained bundles (about 3–4 MB, images embedded). The website v2 prototype is plain HTML, CSS and JS with its assets alongside; v1 is kept in `reference/prototypes/superseded/` for history only. Open it in a browser or Playwright. Do not edit it. Photographs are already extracted to `reference/photography/`; brand SVGs are in `reference/brand/`; tokens are in `design/tokens.css`; a few reference screenshots are in `reference/screenshots/`.

**To read the prototype's real values** (font sizes, paddings, radii, colours, transitions) use:

```
node reference/tools/inspect-prototype.mjs console "table th" 1440 900
node reference/tools/inspect-prototype.mjs website "h1"
```

Never guess a value the prototype already defines. Example: the website hero `h1` computes to about 74.88px at 1440 (a fluid size), not the 72px `--type-display-xl` token. Read the real value, then express it with a token or a documented `clamp()` in `packages/ui`. (The tool needs `playwright` installed in the repo: `pnpm add -D playwright`.)

The prototypes have a discreet **"Prototype controls"** button (bottom-right) that switches role, persona and vault state. In the product this is replaced by real roles and data. Do not ship the control.

## 2. Design principles to protect

- Premium is restraint and craft: typography, proportion, spacing, hairlines. Not decoration.
- Never: generic SaaS or fintech look, default component-library styling, bright saturated colours, gradients (the only gradient permitted is the dark scrim over photography), glassmorphism, heavy shadows, pill buttons, emoji, stock illustration, AI/robot imagery, playful copy.
- Structure comes from rules and space, not boxes. Cards have **no shadow**. One soft shadow token exists, for overlays only (menus, modals, sheets).
- Brass is for significance only: signature, seal, vault, key holders, active verification.

## 3. Tokens

`design/tokens.css` is extracted verbatim from the console prototype. It defines:

- **Colour primitives:** ink 950/900/800/700/600/400/300/200; ivory-50; parchment 100/200/300; brass 300/500/600/700/800; slate 300/500/600/700; sage 300/500/700; ochre 300/500/700; oxblood 300/500; info-300.
- **Semantic tokens (use these in components, not primitives):** `--bg-page/raised/sunken/field/inverse/scrim/hover/selected`, `--text-primary/secondary/tertiary/disabled/inverse/link/link-hover`, `--border-hairline/strong/control/control-hover/emphasis`, `--accent-significance(-text/-soft)`, `--ceremonial-bg/-hover/-text/-rule`, `--action-primary-bg/-hover/-active/-text`, `--focus-ring`, `--status-verified/attention/high-risk/unscored/info` (+ `-text`), `--watermark-ink`.
- **Themes:** `:root` is **Day**. `[data-theme="evening"], .theme-evening` is **Evening**, with extra overrides for `.hl-seal`, `.hl-page`, `.hl-statement`.
- **Type:** `--font-display/heading/text/sans/mono`, `--type-display-xl 72 / l 56 / m 40 / heading-l 28 / m 22 / s 18 / body-l 18 / m 15 / s 13 / label 11 / label-l 12 / mono 13`, leading, tracking (`--tracking-label .1em`, `--tracking-wordmark .32em`), `--measure 68ch`, `--numeric-figures: tabular-nums lining-nums`.
- **Space and layout:** 4/8/12/16/24/32/48/64/96/128, 12-column grid, `--grid-max 1200px`, `--grid-gutter 32px`, `--section-gap 128px`.
- **Density:** `--control-h 44 / sm 36 / lg 52`, `--row-h 56`, `--cell-px 16`, `--density-body 15`, `--card-pad 24`, `--touch-min 44`. The console uses **Compact** (40px rows, 13px body): read the exact overrides from the console prototype and implement them as a `[data-density="compact"]` token layer.
- **Shape and depth:** radius 2px controls, 4px cards and sheets, 50% only for avatars and the seal. Rules `--rule-hairline 1px / fine .5px / emphasis 2px`. One `--shadow-overlay`.
- **Motion:** `--duration-fast 200 / base 250 / slow 300 / ceremony 600`, `--ease-out`, `--ease-ceremony`, `--translate-enter 4px`. Opacity and small translate only. Nothing bounces. The 600 ms reveal is reserved for the seal and the signature moment. Honour `prefers-reduced-motion` (replace motion with an instant state change).
- **Website motion exception (owner decision, 11 Nov 2026).** The marketing website uses scroll-linked choreography exactly as the v2 prototype does: pinned acts, the layered hero (three planes, pointer depth on fine pointers only), the scatter and gather of the register, the land boundary drawing, and the sealing sequence. Scroll-linked motion is paced by the reader and is exempt from the duration tokens. All UI transitions (hover, menus, buttons, fields) stay at 200–300 ms. Nothing bounces. Under `prefers-reduced-motion` every act renders as a composed still with no pinned scroll space (see `css/home.css`, reduced-motion block). Console and portal are unchanged.

**Implementation rules**
1. Import `design/tokens.css` once in each app's global CSS. Do not copy values into components.
2. The Tailwind theme maps to the variables (`colors.page: 'var(--bg-page)'`, `fontSize`, `spacing`, `borderRadius`, `boxShadow.overlay`, `transitionDuration`). Provide semantic utilities (`bg-page`, `text-primary`, `border-hairline`). Primitive colours (`ink-900`) are available but semantic names are preferred in components.
3. A lint rule (or a CI grep) fails the build on hex colours, `px` font sizes or `box-shadow` literals outside `design/tokens.css` and `packages/ui`.

### Fonts
The tokens list licensed faces first and free fallbacks after: Display **Canela / GT Super Display → Cormorant Garamond**; text serif **Tiempos Text → Newsreader**; UI sans **Söhne → Geist**; mono **Söhne Mono → Geist Mono**. The prototypes render with the fallbacks. Load the fallbacks with `next/font` (self-hosted, `display: swap`, subset Latin + Latin Extended so Yoruba diacritics render). Cormorant Garamond is for display sizes only (32px and up). Wiring the licensed fonts later is a one-line change to the font loader; the token stacks already list them. **[DECIDE]** font licensing (see `docs/05`).

## 4. Components (`packages/ui`)

Build every component with all states (default, hover, focus, active, disabled, loading, error), in Day and Evening, Comfortable and Compact where applicable. Match the prototype pixel for pixel.

| Group | Components |
|---|---|
| Actions | Button: **Primary** (ink fill, ivory text), **Secondary** (hairline outline), **Tertiary** (text with refined underline), **Ceremonial** (brass; only Sign statement, Seal vault, Confirm release), **Destructive** (oxblood outline) |
| Inputs | Text, textarea, select, date, currency (₦ / $), search, 6-digit OTP, file drop zone with "Encrypted" confirmation state, checkbox, radio, level selector (heir levels) |
| Data | **Masked value** (`•••• 4471` + eye-off + "Reveal (logged)"; revealed state with 30-second timer and "logged" note), **Status indicator** (dot + small-caps label: Verified, Evidenced, Claimed, Disputed, Needs review, High risk, Unscored; never a filled pill), Table (small-caps header, hairline rows, sortable, selectable, sticky header, loading/empty states), summary card with display-serif figure, asset card, alert card, key-holder card |
| Navigation | Console sidebar (Evening: ink with ivory text, brass active marker), top bar, breadcrumbs, underline tabs, portal bottom nav (Home, Register, Alerts, Vault, More), website header (slim ivory bar on scroll) and footer, refined full-screen mobile menu |
| Feedback | JIT banner (brass rule, countdown, "All views logged"), info/warning/error banners, content-free toasts, inline validation, confirmation dialogs, bottom sheets (mobile), skeleton rows, empty and error states in calm copy |
| Progress | Engagement stage bar (six stages), vertical release timeline with waiting-period counter, checklist progress |
| Specialised | Document viewer frame (page thumbnails, zoom, field region highlights), extraction field row (value, confidence bar, examiner chip Match / Mismatch / Not found, Accept / Edit / Mark unreadable), match candidate card (score bar with threshold marker), risk score card (large band label, rule-hit breakdown, rules version), fee estimate card, map frame with parcel outline, before/after satellite compare with draggable divider, verification statement block with brass seal and signature line, key-holder diagram (2 of 3 keys), kanban column/card with SLA timer |
| Brand | Wordmark (HEIRLINE, display serif, `--tracking-wordmark`), monogram H in a thin circular rule (app icon, favicon, PWA icon), **seal** (brass; only for signed statement, sealed vault, release confirmation), watermark guilloche pattern (report covers and vault backgrounds, never behind body text) |
| Icons | Custom thin-line set, 1.25px stroke, 20/24 grid, square terminals: land/plot, title deed, shares, bank, pension, policy, business, receivable, globe, vault, key, seal, shield, eye-off, eye, document, upload, search, filter, alert, check, clock, user, family, lawyer, satellite, map pin, timeline. If the prototype ships these as inline SVG, lift them into `packages/ui/icons`. |

## 5. Themes by surface

| Surface | Sidebar / chrome | Content | Density |
|---|---|---|---|
| Console | Evening | Day | Compact |
| Portal | Day | Day, **Evening for vault screens** | Comfortable |
| Website | Day | Day | Comfortable |

## 6. Screen map

### Console (1440) — 14 screens
| # | Screen | Prototype flow | Notes |
|---|---|---|---|
| 1 | Sign in + MFA | F1 | Left column: wordmark, "CONSOLE · STAFF ONLY", "The register of every family we serve." Footer line "Heirline Console · Lagos · <date>". Step 2: "Enter your code" (6-digit OTP). |
| 2 | Engagements list | F1→ | Columns: code name, product, stage, analyst, verifier, due, payment. Filters by product and stage. |
| 3 | Engagement overview | F0 | Six-stage bar; Checklist, Open tasks, Findings summary, Team. **No asset details.** |
| 4 | My tasks | F2 | Grouped by due date; each shows code name and "Access: …" scope. |
| 5 | Document intake | F2 | Drop zone; table with thumbnail, detected type, pages, status chips (Encrypted ✓, Classified, Extracting, Needs review, Unreadable → manual entry). |
| 6 | Extraction review | F2 | **Most important screen.** Split view; region highlight; amber mismatch rows with examiner notes. |
| 7 | Discovery matcher queue | F3 | "Nothing is confirmed automatically." |
| 8 | Register (scoped) | F4 | Tabs by asset class; scope banner. |
| 9 | Parcel detail | F5 | Map, title summary, risk card, fee card. |
| 10 | Perfection plan | F5 | Ranked table plus editable narrative. |
| 11 | Recovery cases | F6 | Kanban, six columns. |
| 12 | Verification and sign-off | F7 | **Signature moment.** Brass JIT banner; seal reveal 600 ms. |
| 13 | Reports and packets | F8 | Secure link, 7-day expiry, revoke, watermark preview. |
| 14 | Audit log | F9 | "Audit chain verified ✓". |

### Portal (390 mobile + 1440 Home) — 11 screens
Sign in; Principal home (+ desktop); My register; Land plot detail; Land watch alert; Recovery tracker; **Family vault** (Evening); Who sees what; Heir view; **Executor release in progress** (Evening); Executor day-one pack. Vault and executor release are the emotional core. Build them with the most care.

### Website (1440 + 390): v2
Spec: `reference/prototypes/website/`. Reference screenshots: `reference/screenshots/website-v2-*.png`.

**Home** keeps the 8 approved headings in order (§7 item 8), staged as acts. Spans are in viewport heights.

| Act | Heading | Behaviour |
|---|---|---|
| Hero (Evening, pin 2.1) | Everything your family owns. Verified, protected, ready. | Three photographic planes (sky, lagoon and city, terrace) from one 4K still. On scroll the terrace rises and evening falls (ink overlays, city lights brighten). Pointer depth on fine pointers only. On phones the subline moves above the headline and the type sits above the terrace |
| Problem (Day, pin 2.9) | A family's wealth is rarely in one place. | Ten asset slips drift apart. Visitors may mark theirs (buttons, `aria-pressed`). On scroll the marked ones (or an example set) gather into a ledger with status Claimed |
| What Heirline does (Evening, pin 3.0) | Find. Verify. Protect. Prepare. | Ink panel plus land aerial. The four verbs step through. A brass boundary draws between beacons (active verification). A "watched by satellite" frame appears at Protect |
| How it works (Day, flow) | Four steps, taken at your pace. | Deed image with a reveal. The visitor's register steps Claimed, then Evidenced, then Verified (one entry Disputed) as steps II and the sign-off pass. ICAN, agreed-upon procedures, not an audit opinion |
| Interlude (Evening, flow) | none | One line naming death and incapacity gently. Intentional silence before the peak |
| Independence and security (Evening, pin 4.0, the peak) | Signed off independently. Sealed by design. | The register folds. Two key holders (You, Your lawyer) turn; Heirline's key stays with "Cannot open it alone". The brass seal presses into the plate. Line: "The sealed vault opens with the Heirline client portal." (vault is V1) |
| Services (Day, raised, pan 3.3) | Four services, one verified register. | Horizontal rail: lead, four service rooms with photographs, closing CTA |
| Insights (Day, flow) | Quiet, practical writing. | Three entries as a hairline list |
| Consultation (Day, flow) | Book a private consultation | The F10 form set as a letter, pre-filled from the visitor's marks, beside their sealed register |

**Folio:** a small fixed panel showing the visitor's register. It appears only where the register is not already on screen (Find, Interlude, Services, Insights).

**Register state** lives in `sessionStorage` (`hl-register-v1`) only, carries to the consultation page, and is never sent except as the topic chips the visitor chooses to submit.

**Service page template:** `health-check.html` (title page with facts, what we look for, an illustrative risk card with rules version, what you receive with the brass-sealed statement, FAQ accordion, CTA).

**Consultation page:** `consultation.html`.

**Header:** a fixed bar that re-themes to the ground beneath it (transparent on the hero, ink on Evening once scrolled, ivory on Day), with the full-screen menu on phones.

## 7. Copy corrections to apply (the prototype is approved except for these)

1. Vault diagram label is **KEY HOLDER**, never "Custodian". Heirline never holds assets.
2. Console sign-in line: "Every view of a family's record is logged and reviewed by our **data protection officer**."
3. Website footer and entity block: **Heirline Nigeria Limited · 26 Dipeolu Street, by Allen Avenue, Awolowo Way, Ikeja, Lagos · enquiries@heirline.ng · Lagos · London.** Footer carries the real logo and tagline "Verified. Protected. Ready."
4. Portal "needs attention" panel copy is **"Each one is in hand"**, with an owner for each item (Lekki parcel 2: your lawyer; Ibadan: surveyor visit; Ijebu-Ode: awaiting charting). Do not use alarming language.
5. The sealed seal text reads "HEIRLINE · LAGOS · EST. 2026". **[VERIFY]** the incorporation year before launch.
6. No guarantees of outcomes, amounts or timelines anywhere. Legal work is "our partner law firms".
7. The prototype footer shows **+234 1 234 5678**. That is a placeholder. Read the real phone number from an environment/config value (`SITE_PHONE`) and **hide the line if it is not set**. The same applies to `enquiries@heirline.ng` until the mailbox exists.
8. Website Home section headings in the prototype, in order: "Everything your family owns. Verified, protected, ready." / "A family's wealth is rarely in one place." / "Find. Verify. Protect. Prepare." / "Four steps, taken at your pace." / "Signed off independently. Sealed by design." / "Four services, one verified register." / "Quiet, practical writing." / "Book a private consultation". Keep this copy exactly.
9. Website v2 additions (approved with the prototype): the hero second line "Land, shares, accounts, and the things only one person remembers. We find them, prove them, and keep them ready for the day your family needs them."; the interlude line; "Mark what your family holds. Nothing you mark leaves this page."; the footer fraud notice "We will never ask you to send money, passwords or one-time codes by email, telephone or WhatsApp."; the F10 confirmation "Thank you. A member of our team will contact you discreetly within one working day."

## 8. Imagery

Use only the photographs in `reference/photography/` and the website v2 assets in `reference/prototypes/website/assets/`. They are warm, desaturated, architectural and archival, with no people. The website v2 hero is a 4K still, cut into three planes (`h-sky`, `h-mid`, `h-fg`, plus `h-lights`). The 4K masters are in `reference/photography/masters/`. The v1 1344 px hero and the v1 deed image (British-style crest, AI stamp artefacts) are superseded. Apply the prototype's dark scrim over photography so overlaid text passes contrast. Never add handshakes, people in suits, AI/robot imagery or stock illustration.

## 9. Accessibility (non-negotiable)

WCAG 2.1 AA minimum for every text/background pair (the design system defines a contrast matrix: re-check it in code with an automated test). Visible focus ring: 2px `--focus-ring` with 2px offset (ink-600 on Day, brass-300 on Evening). Status never by colour alone. Touch targets ≥ 44px. Portal body text ≥ 15px. Support 200% zoom and reduced motion. All interactive components keyboard operable; dialogs trap focus; toasts are announced politely.

## 10. Proving fidelity (`pnpm fidelity`)

Build this harness in Phase 0 and run it on every screen.

1. A Playwright project loads the prototype file and the running app at the same viewport (1440×900 or 390×844), same theme/role/state, with **animations disabled** and fonts loaded. Both use the KESTREL fixture so content matches.
2. For each screen id in `packages/ui/fidelity/screens.ts` (screen id → prototype navigation steps → app route), take a full-page screenshot of each.
3. Compare with `pixelmatch` (or Playwright `toHaveScreenshot`) at a **threshold of 0.1 and a max differing-pixel ratio of 2%**. Mask regions that legitimately differ (dates, prototype controls, live timers).
4. On failure, write a side-by-side diff image to `fidelity-report/` and fail the run.
5. Add token-level assertions: computed `font-family`, `font-size`, `color`, `border-radius`, `padding` on key elements equal the prototype's (`reference/tools/inspect-prototype.mjs` shows the values).
6. Add motion assertions: seal reveal duration is 600 ms with `--ease-ceremony`; all other transitions 200–300 ms; with `prefers-reduced-motion` the reveal is instant. For the website, compare pinned acts at fixed scroll positions (act progress 0, 0.5, 1) rather than by duration, and confirm the reduced-motion render has no pinned scroll space.
7. Axe accessibility scan on every screen: zero serious or critical violations.
8. Report in the PR: which screens were compared, diff ratio per screen.

A screen is "done" only when the diff passes and the screenshot of the build is attached to the PR next to the prototype's.
