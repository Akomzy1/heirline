# Heirline build pack

Everything Claude Code needs to build Heirline so that it matches the approved prototypes.

## What is in here
| Path | What |
|---|---|
| `CLAUDE.md` | Project instructions Claude Code reads every session. Non-negotiables, stack, vocabulary, definition of done. |
| `.claude/skills/` | Three project skills: UI fidelity, security guardrails, rules and AI. |
| `docs/01_MVP_Scope.md` | What is in and out, build order, exit criteria. |
| `docs/02_User_Flows.md` | Every flow step by step, with failure paths and audit events. |
| `docs/03_UI_Fidelity_Spec.md` | Tokens, components, screen map, copy corrections, and how fidelity is proved. |
| `docs/04_Build_Prompts.md` | **The prompts to paste into Claude Code, in order.** |
| `docs/05_Decisions_and_Gaps.md` | Open decisions, accounts and keys you must provide, launch checklist. |
| `docs/06_KESTREL_Fixture.md` | The synthetic demo family and known discrepancies. |
| `db/` | Migrations 0001–0006 (tested, 61/61), V1 migration 0100, tests, KESTREL seed JSON. |
| `design/` | `tokens.css` (extracted verbatim from the prototype) and a Tailwind theme mapped to it. |
| `reference/prototypes/` | The approved prototypes. The specification for look, layout, spacing, copy and motion. Read-only. |
| `reference/photography/`, `brand/`, `screenshots/` | Images, logo SVGs and reference screenshots extracted from the prototypes. |
| `reference/specs/` | PRD v0.1, TRD v0.1 and the original design prompts. |
| `reference/tools/inspect-prototype.mjs` | Prints a prototype element's real computed styles. |

## How to start
1. Create a new Git repo. Unzip this pack at its root. Commit.
2. Open Claude Code in that folder, in plan mode.
3. Open `docs/04_Build_Prompts.md` and paste **S0**, then **Prompt 0**, **Prompt 1**, and so on, one at a time. Check each phase's gate and screenshots before the next.
4. Do the non-code items in `docs/05_Decisions_and_Gaps.md` section 6 in parallel (counsel, DPIA, accounts, name clearance). They, not the software, will decide the first-client date.

## Three things to know before you start
- **The website is the quickest visible win** (Prompt W). It can start as soon as Prompt 1 is done.
- **The client portal and vault are V1.** The prototype exists, but the MVP is the staff console plus the website. Do not start the portal early.
- **Placeholders that must not reach a real client:** the demo rule weights (calibration pending), the placeholder phone number, consent and engagement-letter texts (need counsel), and the website prototype's illustrative register, risk card and non-sending form.
- **The website prototype is v2** (approved 11 Nov 2026): `reference/prototypes/website/`. Serve it over HTTP and read its `PROTOTYPE_NOTES.md`. The v1 files are in `reference/prototypes/superseded/` for history only.
