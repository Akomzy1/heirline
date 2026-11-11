# Photography

## Website v2 (current, approved 11 Nov 2026)
The web-ready files used by the prototype are in `../prototypes/website/assets/`. The full-resolution masters are in `masters/` (JPEG, quality 2, from the 3840 or 2560 px PNG originals). All were generated on Higgsfield with GPT Image 2.6 at 4K, using one shared style preamble so they read as one shoot. They contain no people, no legible text and no crests.

| Master | Size | Used for | Web files |
|---|---|---|---|
| `01-hero.jpg` | 3840×2160 | Home hero (dusk terrace, Lagos lagoon) | `h-sky`, `h-mid`, `h-fg`, `h-lights`, `h-poster` (planes cut locally; see `scrollcraft/builds/heirline/tools/planes.html`) |
| `05-deed.jpg` | 3840×2160 | How it works; service page hero | `deed.webp` |
| `06-archive.jpg` | 2560×3200 | Estate Asset Trace | `archive.webp` |
| `07-heir.jpg` | 2560×3200 | Heir Readiness | `heir.webp` |
| `08-land.jpg` | 3840×2160 | Find. Verify. Protect. Prepare.; Health Check card | `land.webp` |

`private-study.jpg` (below) is still used, for the Continuity Retainer card (`study.webp`).

## From the v1 prototypes
| File | Size | Status |
|---|---|---|
| hero-lagoon-terrace.jpg | 1344×752 | Superseded by `masters/01-hero.jpg`. Still the portal sign-in background (V1) until the portal is revisited |
| private-study.jpg | 896×1120 | In use (Continuity Retainer) |
| deed-and-survey-plan.jpg | 1024×688 | **Do not use.** British-style crest and AI stamp artefacts. Replaced by `masters/05-deed.jpg` |
| land-parcels-aerial.jpg | 1344×752 | Superseded by `masters/08-land.jpg` |
| satellite-before.png / satellite-after.png | 800×500 | Portal land-watch placeholders. V1 replaces them with licensed imagery |

Rules: serve through `next/image` with responsive sizes; keep alt text meaningful; text over photography needs the dark scrim (the one permitted gradient) or a solid panel; never use stock photography of people.
