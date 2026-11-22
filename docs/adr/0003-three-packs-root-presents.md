# 0003. Split the code into three packs (impact, catalog, surveys) and keep pages in the root app

Status: Accepted (2026-11-21)
Answers: C2

## Context
C2: one deployable app in modules with enforced boundaries, and the rules module
depends on nothing. The spec has three capabilities (impact.md, catalog.md and
survey.md), each with its own pack. The baseline has one pure pack, `packs/scoring`,
which IH-7 and `test/boundaries_test.rb` keep free of Rails.

## Decision
| Pack | Holds | Depends on |
|---|---|---|
| `packs/impact` | rules and values, pure Ruby | nothing (`enforce_dependencies: strict`) |
| `packs/catalog` | barrier models, seed, `Catalog.barriers_for`, the IH-22 notice | `packs/impact` |
| `packs/surveys` | survey and point models, use cases | `packs/impact`, `packs/catalog` |
| root (`app/`) | controllers, page resources, React pages | all three |

- Packs never depend on the root.
- `packs/scoring` and its tests are deleted, and `test/boundaries_test.rb` points at
  `packs/impact`.
- **Why catalog depends on impact:** it builds `Impact::Barrier` values and checks
  `application` against `Impact::APPLICATIONS`, so that list is written once.

**Options considered:**
- A catalog that depends on nothing: it would repeat the application list.
- The catalog folded into surveys: catalog.md is its own capability, and a pack per
  capability keeps the spec index and the code in step.

## Consequences
- Packwerk enforces the arrows above, and the impact pack stays testable alone.
- The phase 4 sensor pack will depend on surveys, and the phase 5 proposal pack on
  surveys and catalog.
- Pages sit in the root app because they combine all three packs.
