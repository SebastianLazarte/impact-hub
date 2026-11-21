# packs/impact

Pure Ruby rules: hazard point facts, required energy, barrier matching and verdicts.
Spec: [docs/specs/impact.md](../../docs/specs/impact.md). Boundaries: C2 in [docs/specs/system.md](../../docs/specs/system.md).

## Rules
- Depends on nothing; `package.yml` has `enforce_dependencies: strict` and `dependencies: []`.
- No Rails, ActiveRecord, HTTP, LLM or other-pack constants (IH-7, [test/boundaries_test.rb](../../test/boundaries_test.rb)).
- An unknown fact is `Impact::Fact.unknown`, never `nil` or `0` in its place (P3).
- Energy arithmetic follows ADR 0001.

## Verify
`bin/rails test packs/impact test/boundaries_test.rb test/traceability_test.rb && bin/packwerk check`
