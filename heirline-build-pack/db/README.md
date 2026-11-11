# db

Migrations for the Heirline MVP, written from TRD §5 and tested against Postgres 16.

| File | What |
|---|---|
| `migrations/0001` | schemas, enums, `enc_blob` domain, helpers |
| `migrations/0002` | `crypto.family_keys`, `identity.*` |
| `migrations/0003` | `evidence.*`, `register.*` |
| `migrations/0004` | `ops.*`, `leads.*` |
| `migrations/0005` | config packs, verification + JIT, audit hash chain + AI call log |
| `migrations/0006` | RLS helper functions, force-RLS everywhere, SELECT-only policies, coverage guard |
| `migrations/0100` | **V1 only** (vault, monitor, will health check). Do not apply in the MVP. Needs PostGIS and policies + tests written in Track C. The SQL was syntax-checked with a PostGIS stand-in; apply it against a real PostGIS-enabled database to validate. |
| `tests/00_local_stubs.sql` | `auth.uid()`, `auth.users` and Supabase roles for plain Postgres. **Skip on Supabase.** |
| `tests/10_schema_and_rls_tests.sql` | 61 assertions: RLS per role, JIT, fail-closed constraints, config immutability, audit chain tamper detection |
| `seed/kestrel.fixture.json` | The synthetic KESTREL family (26 assets, 23 verified) |

## Run the tests on plain Postgres
```bash
createdb hl_test
psql -v ON_ERROR_STOP=1 -d hl_test -f tests/00_local_stubs.sql
for f in migrations/000{1..6}_*.sql; do psql -q -v ON_ERROR_STOP=1 -d hl_test -f "$f"; done
psql -q -d hl_test -f tests/10_schema_and_rls_tests.sql     # last lines: passed | failed -> 61 | 0
```
On Supabase local, skip the stubs and run the same migrations and test file.

## Rules that the database enforces (not just the app)
- `ops.engagements`: the verifier cannot also be an assigned analyst; `ops.verifications`: preparer ≠ signer; a signed verification is immutable; signing needs a complete, non-empty checklist and a signature reference.
- `evidence.evidence_items`: only an examiner `match` or a named human resolution can create one.
- `ops.recovery_cases`: cannot be `recovered` without an outcome value and evidence.
- `ops.match_candidates`: any decision needs a human decider.
- `ops.report_links`: expiry ≤ 7 days. `ops.payments`: unique provider reference (idempotent webhooks).
- `config.config_versions`: sha256 must match content; approver ≠ author; approved versions are immutable.
- `ops.jit_sessions`: reason ≥ 10 chars; 4h default; one renewal up to 8h.
- `audit.events`: append-only (no update, delete or truncate), hash-chained, `audit.verify_chain()` detects tampering.
- Every table: RLS enabled and forced; `public.rls_coverage_gaps()` returns no rows.
