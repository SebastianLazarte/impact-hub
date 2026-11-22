# packs/catalog

The read-only, fictional, seeded list of barriers the impact rules choose from.
Spec: [docs/specs/catalog.md](../../docs/specs/catalog.md). Boundaries: C2 in [docs/specs/system.md](../../docs/specs/system.md).

## Rules
- Depends on: `packs/impact`, declared in `package.yml`. Nothing else.
- `Catalog::Seed.call` is the only write path; it is idempotent. Names are generic codes, never a manufacturer's (C4).
- Every barrier is tested at 45° and 90°, the 90° energy not above the 45° one (IH-22, [catalog_test.rb](test/catalog/catalog_test.rb)).
- `Catalog::NOTICE` is the one home of the "example values, not manufacturer data" text.

## Verify
`bin/rails test packs/catalog test/traceability_test.rb && bin/packwerk check`
