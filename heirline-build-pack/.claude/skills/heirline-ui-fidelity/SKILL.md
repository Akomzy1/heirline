---
name: heirline-ui-fidelity
description: Use before building or changing any Heirline UI (console, website, portal). Makes the approved prototypes in reference/prototypes the source of truth and enforces tokens, copy rules and the fidelity check.
---

# Heirline UI fidelity

The approved design is `reference/prototypes/{console,portal}.html` and the website prototype in `reference/prototypes/website/` (v2). The built UI must be visually indistinguishable from it. Full detail: `docs/03_UI_Fidelity_Spec.md`.

## Before writing UI
1. Identify the screen id and its prototype file and viewport (console 1440, website 1440 and 390, portal 390 with desktop Home 1440).
2. Open the prototype in Playwright and screenshot the screen. For exact values run `node reference/tools/inspect-prototype.mjs <console|portal|website> "<selector>"`. Do not guess any value the prototype defines.
3. Check `packages/ui` for the component. If it is missing, add it there first, matching the prototype. Pages compose components; they never restyle them.

## Hard rules
- Tokens come from `design/tokens.css` (mirrored into `packages/ui`). No hard-coded hex, px font size, radius, shadow or duration that has a token. Semantic token names in components (`--bg-page`, `--text-primary`, `--border-hairline`), not primitives.
- Themes: Day is default; Evening for the console sidebar and portal vault screens. Console uses Compact density; portal and website Comfortable.
- No shadows on cards (only `--shadow-overlay` for menus, dialogs, sheets). Radius 2px controls, 4px cards. No gradients except the dark scrim over photography. No pill buttons, emoji, stock imagery, AI/robot imagery.
- Brass only for signature, seal, vault, key holders and active verification. Never body text, never decoration. Ceremonial button only for Sign statement, Seal vault, Confirm release.
- Status = dot + small-caps label, never colour alone, never a filled pill.
- Motion 200–300ms ease-out, opacity and 4px translate only; 600ms ceremony reveal only for the seal and signature. Honour `prefers-reduced-motion`.
- **Website exception (approved 11 Nov 2026):** the marketing website follows the scroll choreography in `reference/prototypes/website/` (pinned acts, layered hero, the register and sealing sequence). Scroll-linked motion is paced by the reader, so it is exempt from the duration rule. UI transitions on the website still stay within 200–300ms. Console and portal are unchanged.
- Accessibility: WCAG 2.1 AA, visible 2px focus ring, 44px touch targets, portal body ≥15px, keyboard operable, dialogs trap focus.

## Copy and vocabulary
- "Key holder", never "custodian". Staff UIs show code names (KESTREL), never surnames; masked refs `•••• 4471`; naira as ranges.
- Calm, precise, unhurried. No exclamation marks, no guarantees of outcome, amount or timeline. Legal work is "our partner law firms". Website: no testimonials, logo strips, pricing, unsourced statistics.
- Apply the copy corrections in `docs/03_UI_Fidelity_Spec.md` section 7.

## Before finishing a screen
Run `pnpm fidelity` for the screen. Attach the build screenshot beside the prototype's. The diff ratio must be ≤ 2% (threshold 0.1) with only legitimately dynamic regions masked. Never raise the threshold to pass.
