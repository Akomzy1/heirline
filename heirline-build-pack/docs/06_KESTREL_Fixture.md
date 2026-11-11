# 06 — KESTREL fixture (the synthetic demo family)

All prototypes tell one story about a fictional family with the code name **KESTREL**. Seeds, tests, fidelity runs and demos all use this family so the build matches what was approved. **Everything here is fictional. No real client data is ever used outside production.**

Machine-readable: `db/seed/kestrel.fixture.json`. Source: `reference/specs/Heirline_Prototype_Prompts.md` (P0).

## The family
- Principal "Chief A." (67, business owner, Lagos). Spouse "Mrs F.".
- Heirs: **Tolu** (eldest son, London, level "categories only", also the executor), **Kemi** (daughter, Lagos, level "plan exists + who to call"), **Dayo** (youngest son, level "nothing yet").
- Partner law firm "Adeyemi & Co."; trustee "Crestfield Trustees".
- Staff: **Bisi** (analyst), **O. Akomolede** (verifier, "ICAN •••• 3318"), an admin, a DPO.

## The register: 26 assets, 23 verified, 3 need attention
| Class | Items |
|---|---|
| Land (5) | Lekki Phase 1 (registered C of O, **low**); **Lekki parcel 2** (unregistered deed, name mismatch, **high, 58**); **Ibadan, Akobo** (survey plan only, **moderate**, encroachment alert open); Abuja, Lokogoma (Governor's Consent, **low**); **Ijebu-Ode** family land (family conveyance only, **critical, unscored** until charting returns) |
| Shares and dividends (10) | 6 listed holdings across Registrar A and Registrar B (2000s); 4 unclaimed-dividend items, **₦18m–₦26m identified** (always a range) |
| Bank (5) | 4 active; 1 dormant at "Bank C" (match confirmed, claim in progress, `•••• 9102`) |
| Pension and policies (3) | 1 RSA; 2 life policies |
| Business (1) | 40% stake in a private distribution company |
| Money owed (1) | ₦35m loan to a relative, documented by a signed note |
| Abroad (1) | London flat (catalogued; UK counsel coordinates) |

"3 need attention" are Lekki parcel 2, Ibadan and Ijebu-Ode. In client copy they read "Each one is in hand", with an owner for each.

## Engagements for list views
KESTREL (Health Check, **Verification**), OSPREY (Estate Asset Trace, Discovery), HERON (Continuity Retainer, Delivered), MERLIN (Health Check, Onboarding), PLOVER (Heir Readiness, Onboarding).

## Dates
Today in the fixture is **9 November 2026**. Vault sealed **12 October 2026**, version **4**. Land watch last checked **7 November 2026**. Cooling-off demo: day 9 of 14.

## Conventions
- Staff UIs: code names only, masked references `•••• 4471`, naira as ranges.
- Client UIs: "Chief A.", first names only.
- The seed script encrypts identity and register fields through `packages/crypto` like production does. Seeds never write plaintext into `enc_blob` columns.
- The synthetic full name in the JSON (used for matcher and extraction tests) is invented. Treat it as test data only.

## Known discrepancies to resolve (do not paper over)
1. **Rule weights.** The prototype shows Lekki parcel 2 as "HIGH (58)" with hits +30 unregistered deed, +10 occupation unknown, +18 name mismatch. The TRD's placeholder pack uses +20 for a name mismatch (total 60). The weights are placeholders until calibrated with the partner law firm and surveyor (TRD decision 6). Build the engine config-driven, seed the pack that reproduces the prototype's 58 for the demo, and mark the pack `DEMO ONLY — not calibrated`.
2. **Ibadan encroachment alert** is a V1 monitoring feature. In the MVP console it appears only as a finding on the parcel.
3. **Abuja and Ijebu-Ode** sit outside the Lagos rules pack. In the MVP they are recorded and shown with band `unscored` until the FCT and Ogun packs exist (V1), except where the prototype shows a band. For the demo seed, set the displayed bands explicitly from the fixture and flag them as demo values.
