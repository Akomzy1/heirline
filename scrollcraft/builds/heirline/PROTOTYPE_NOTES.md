# Heirline website prototype v2: notes for the build pack

Owner-requested remake of `reference/prototypes/website.html` (11 Nov 2026). The original prototypes in `heirline-build-pack/reference/` were not edited. This folder is the proposed replacement for the **website** only. Portal and console are unchanged.

## Pages
| File | Phase W screen |
|---|---|
| `index.html` | Home (all 8 approved headings, in their approved order) |
| `health-check.html` | Service page template (Land & Paper Health Check) |
| `consultation.html` | Book a private consultation |

Run: `node <scroll-craft>/scripts/serve.mjs --root . --port 4500`, then open http://localhost:4500.

## What stays exactly as the brand defines it
Logo files (unchanged SVGs, used at or above the 160px horizontal minimum), `css/tokens.css` (verbatim copy of `design/tokens.css`), Day/Evening themes, Cormorant Garamond / Newsreader / Geist / Geist Mono, brass only for significance (seal, key holders, active verification), status as dot plus small-caps label, the copy rules (no guarantees, no pricing, no testimonials, no statistics, "our partner law firms", "key holder", agreed-upon procedures not an audit opinion), the footer entity line and tagline.

## Decisions that need recording in the build pack if approved
1. **Motion extension, website only** (owner decision, 11 Nov 2026). Scroll-linked choreography (pinned acts, layered parallax, a 4.0vh sealing sequence) is allowed on the website. UI transitions stay 200 to 300ms. Console and portal keep the original rule. Update `docs/03_UI_Fidelity_Spec.md` §3 Motion and the brand direction "Motion" line.
2. **The register interaction** (signature move). Visitors may mark ten common asset categories or add their own under "Something else" (a label of a word or two). The selection lives in `sessionStorage` only and pre-fills the consultation form's topics. The free-text label is never submitted, and no values, locations or names are collected. Needs a line in the privacy notice and DPIA.
3. **Fixed footer notice** on fraud: "We will never ask you to send money, passwords or one-time codes."
4. Phone number and `enquiries@heirline.ng` are **omitted**, per §7 item 7 (hide until real).
5. "The sealed vault opens with the Heirline client portal" is shown because the vault is V1.

## Placeholders that must not reach a real client
- The illustrative register entries, the risk card (HIGH 58, rules NG-LA 2026.11.0) and the "last checked 3 Nov 2026" label are fictional and labelled or framed as examples.
- The form does not send. It shows a confirmation marked "Prototype".
- Seal text "EST. 2026" [VERIFY incorporation year].

## Assets
New Higgsfield stills (GPT Image 2.6, 4K): dusk terrace hero, deed and survey macro (replaces the old image with a British-style crest and fake stamps), archive room, window seat with adire, beaconed land aerial. Hero depth planes were cut locally from the 4K still (`tools/planes.html`), including a clean sky plate. Originals in `out/`.

**Pending:** the two approved clips ("evening falls" on the lagoon, aerial drift over the plots) were not generated. The Higgsfield account hit its grace-period daily limit after five stills (about 21 credits used of the approved ~80). The page already delivers both moments in code, so the clips are an optional upgrade once the limit resets.

## Verification done
Scroll harness at 1440x900, 390x844 and reduced motion: no dead scroll, all cues at or above 4.5:1 on the composited frames. Functional script (`tools/functional.mjs`): 27/27 pass (marks, letter pre-fill, validation and focus, confirmation, POST method, cross-page carry-over, menu focus and Escape, no horizontal overflow, no page errors).

**Not verified:** a real iPhone or Android device, Safari, slow-network behaviour, screen readers. Research gap: the Nigerian trust-signal and sourced-statistics research did not complete, so the site carries no market figures.
