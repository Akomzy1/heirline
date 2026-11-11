# Heirline — Design system prompt for Claude Design

Paste the prompt below into the same Claude Design project that holds the wireframes. Once the system is generated, use the follow-up prompt at the end to apply it to the wireframes.

---

## Prompt

```
Create the complete design system for HEIRLINE, a highly premium private-client service for Nigerian high-net-worth families (at home and in the diaspora). Heirline finds, verifies and safely records everything a family owns, protects it, and releases it to the right people when the head of the family dies or loses capacity. Clients are wealthy, usually 50+, and use the private-banking apps of the best global banks. This system must make Heirline look and feel like it belongs in that world. It will style three surfaces that already exist as wireframes in this project: (1) the staff console (dense, desktop), (2) the client / heir / executor portal (calm, mobile-first), (3) the marketing website (editorial).

BRAND ESSENCE
- Discretion, permanence, trust, lineage. Quiet confidence. Old-world craft, modern precision.
- Reference points for the feeling (not to copy): a Swiss private bank's client materials, a heritage law firm, a luxury watchmaker's catalogue, fine stationery and archival documents.
- Premium = restraint and craft. Luxury lives in typography, proportion, spacing and detail, never in decoration, gradients or glitter.
- NEVER: generic SaaS or fintech look, default component-library styling, bright saturated colours, gradients, glassmorphism, heavy drop shadows, pill buttons everywhere, emoji, stock illustration, AI/robot imagery, playful copy.

1. FOUNDATIONS — COLOUR (create named tokens; show each swatch with hex and WCAG contrast results)
- Ink (primary): ink-950 #0B1220, ink-900 #0E1726, ink-800 #16213A, ink-700 #223052, ink-600 #34466E, ink-400 #6B7A99, ink-200 #B9C1D3.
- Ivory / parchment (surfaces): ivory-50 #FAF7F0 (page), parchment-100 #F3EEE3 (raised surface), parchment-200 #E8E0CF (hairlines on light), parchment-300 #D8CDB6.
- Brass (significance only): brass-300 #CDB585, brass-500 #A8874A, brass-600 #8C6F3A, brass-700 #6E5629. Brass marks moments that matter (signature, seal, vault, key holders, active verification). It is never used for body text on ivory and never used decoratively.
- Slate (UI chrome and secondary text): slate-300 #C9CDD3, slate-500 #7C8593, slate-700 #4A5260.
- Status (desaturated, always paired with a text label, never colour alone): verified = sage #5F7A63, attention = ochre #A86F24, high risk = oxblood #7A2E2E, unscored = slate #7C8593, info = ink-600.
- Semantic tokens: bg/page, bg/raised, bg/inverse, text/primary, text/secondary, text/inverse, border/hairline, border/strong, accent/significance, focus/ring, plus status tokens.
- Two themes: "Day" (ivory background, ink text) as default for portal and website; "Evening" (ink-950/900 background, ivory text, brass accents) available for the console and for the vault screens.
- Every text/background pairing used must pass WCAG 2.1 AA. Show the contrast matrix.

2. FOUNDATIONS — TYPOGRAPHY
- Display serif (headings, key figures, wordmark): a refined high-contrast serif. Primary choice: Canela or GT Super Display (licensed). Free fallback for prototyping: Cormorant Garamond at display sizes only (32px and up).
- Text serif (long-form editorial on the website, the signed verification statement, letters): Newsreader (or Tiempos Text if licensed).
- UI sans (all interface text, tables, forms): a precise neo-grotesk. Primary choice: Söhne (licensed). Free fallback: Geist or Instrument Sans.
- Numerals: tabular lining figures in all tables, amounts and dates (font-variant-numeric: tabular-nums lining-nums).
- Labels: letter-spaced small caps / uppercase sans at 11–12px, tracking +8–12%.
- Type scale (desktop / mobile): display-xl 72/44, display-l 56/36, display-m 40/30, heading-l 28/24, heading-m 22/20, heading-s 18/17, body-l 18/17, body-m 15/15, body-s 13/13, label 11–12, mono-figures for references. Define line heights (1.1 for display, 1.5 for body) and paragraph width (max ~68 characters).
- Show a type specimen page with real Heirline copy, e.g. "Everything your family owns, verified and kept ready." and a table row of masked figures.

3. FOUNDATIONS — SPACE, GRID, SHAPE, DEPTH, MOTION
- Spacing: 4px base scale (4, 8, 12, 16, 24, 32, 48, 64, 96, 128). Generous outer margins everywhere.
- Density tokens: "Comfortable" (portal, website) and "Compact" (console tables: 40px rows, 13px body) from the same components.
- Grid: 12 columns at 1440px (max content 1200px, 32px gutters); 8 columns at tablet; 4 columns at 390px mobile with 20px margins. Baseline rhythm of 4px.
- Corners: nearly square. Radius 2px for inputs and buttons, 4px for cards and sheets, full circle only for avatars and the seal.
- Borders: hairlines 0.5–1px in border/hairline. Structure comes from rules and space, not boxes.
- Depth: no shadows on cards. One very soft shadow token only for overlays (menus, modals, sheets).
- Motion: 200–300ms, ease-out, opacity and small translate only. A slower 600ms reveal reserved for the vault seal and the signature moment. Nothing bounces. Respect reduced-motion.

4. BRAND ELEMENTS
- Wordmark: "HEIRLINE" in the display serif, generous tracking, with an optional lowercase "Heirline" lockup for the portal.
- Monogram: a fine "H" inside a thin circular rule, usable as app icon, favicon and seal.
- Seal motif: an embossed / wax-seal style mark in brass, used ONLY for the signed verification statement, the sealed vault and release confirmation.
- Watermark pattern: a very faint fine-line guilloche or engraved-line pattern for report covers and vault backgrounds (never behind body text).
- Iconography: custom thin-line icons, 1.25px stroke, 20/24px grid, square terminals, quiet and precise. Provide a starter set: land/plot, title deed, shares, bank, pension, policy, business, receivable, globe/abroad, vault, key, seal, shield, eye-off (masked), eye (reveal), document, upload, search, filter, alert, check, clock, user, family, lawyer, satellite, map pin, timeline.
- Imagery direction (website): architectural details, paper, ink, light falling on surfaces, aerial land textures, archival documents. Warm, desaturated, editorial. Never handshakes, never people in suits pointing at screens.

5. COMPONENTS (each with all states: default, hover, focus, active, disabled, loading, error; in Day and Evening themes; Comfortable and Compact density)
- Buttons: Primary (ink fill, ivory text), Secondary (hairline outline), Tertiary (text with refined underline), Ceremonial (brass, reserved for Sign statement, Seal vault, Confirm release). Destructive (oxblood outline).
- Inputs: text, textarea, select, date, currency (₦ and $), search, 6-digit OTP, file drop zone (with "Encrypted" confirmation state).
- Masked value: shows "•••• 4471" with an eye-off icon and a "Reveal (logged)" action; revealed state shows a small timer and "logged" note.
- Status indicator: small dot + small-caps label (Verified, Evidenced, Claimed, Disputed, Needs review, High risk, Unscored). Not filled pills.
- Tables: refined header (small-caps labels), hairline row separators, compact and comfortable densities, sortable headers, row selection, sticky header, empty and loading states, inline masked values.
- Cards: summary card with display-serif figure; asset card; alert card; key-holder card.
- Navigation: console sidebar (Evening theme, ink with ivory text, brass active marker), top bar, breadcrumbs, tabs (underline style), portal mobile bottom navigation, website header and footer.
- Banners: Just-in-time access banner (brass rule, countdown "3h 42m remaining", "All views logged"), info, warning, error.
- Feedback: toasts (content-free wording), inline validation, confirmation dialogs, bottom sheets (mobile).
- Progress: stage bar for engagement stages; vertical timeline/stepper for the release process with a waiting-period counter.
- Specialised: document viewer frame with page thumbnails and field highlights; extraction field row (value, confidence bar, examiner chip Match/Mismatch/Not found); match candidate card with score bar and threshold marker; risk score card with large band label and rule-hit breakdown; map frame with parcel outline; before/after satellite comparison; verification statement block with seal and signature line; key-holder diagram (2 of 3 keys).
- Empty states and error pages written in calm, respectful copy.

6. VOICE AND TONE (include a short page)
- Calm, precise, respectful, unhurried. Short sentences. Plain English; no jargon without explanation.
- Never alarming, never salesy, no exclamation marks.
- Examples: "Your vault is sealed." / "We found something worth a closer look." / "A surveyor will visit within 7 days to confirm." / "Two of these three keys are needed to open your vault. Heirline cannot open it alone."

7. ACCESSIBILITY
- WCAG 2.1 AA minimum; visible focus ring (2px ink-600 with 2px offset on light, brass-300 on Evening).
- Status never shown by colour alone. Minimum 44px touch targets on mobile. Body text never below 15px in the portal. Support reduced motion and 200% zoom.

DELIVERABLES
1. Foundations pages: colour (with contrast matrix), typography specimen, spacing/grid, shape/depth, motion.
2. Brand elements page: wordmark, monogram, seal, watermark, icon set, imagery direction.
3. Components library with all states, both themes, both densities.
4. Voice and tone page.
5. Three proof compositions using only system tokens and components:
   a) Console — Verification and sign-off screen (Evening sidebar, Day content, ceremonial brass sign button, seal on statement).
   b) Portal mobile — Family vault screen (key-holder diagram, sealed state).
   c) Website — Home hero (editorial, display serif headline, "Book a private consultation").
6. Export the tokens as CSS variables and a Tailwind theme extension (colours, fonts, spacing, radii, shadows, motion), with semantic token names.

Before finishing, review every page against the brand essence and the NEVER list, and refine anything that looks like a default template or a generic fintech product.
```

---

## Follow-up prompt (after the system is generated)

```
Apply the Heirline design system to all existing wireframes in this project: the 14 console screens, the 12 portal frames and the website pages. Use only system tokens and components. Console uses the Evening sidebar with Day content and Compact density; the portal and website use Day theme and Comfortable density. Give extra care to the console sign-off screen, the portal vault and executor-release screens, and the website Home hero. Then review every screen against the premium bar and list any component you had to invent so it can be added to the system.
```

---

## Notes

- **Fonts:** Canela, GT Super and Söhne are commercial fonts and need web licences before launch. The free fallbacks (Cormorant Garamond, Newsreader, Geist / Instrument Sans) are fine for prototyping. Decide before the build starts, because the Tailwind theme will reference them.
- **Colours:** the hex values are a starting palette. If Claude Design adjusts them to pass contrast, accept the adjusted values and update the tokens rather than forcing the originals.
