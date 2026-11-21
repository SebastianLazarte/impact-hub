# packs/scoring

Pure Ruby rules: hours per month, automation score, method and required control.
Spec: [docs/specs/scoring.md](../../docs/specs/scoring.md). Why pure: P1 and C2 in [docs/specs/system.md](../../docs/specs/system.md).

## Rules
- No Rails, ActiveRecord, HTTP, LLM or other-pack constants ([test/boundaries_test.rb](../../test/boundaries_test.rb)).
- Inputs arrive only as `Scoring::StepInput`, which validates and converts to BigDecimal.
- Results that may be unknown are `Scoring::Estimate`, never a bare `nil` or `0`.
- Raise a control only with `Levels.stricter`; never assign a lower one.
- The decision tables live in three places that must agree: the comment in
  [rules.rb](app/services/scoring/rules.rb), `docs/specs/scoring.md` and the tests.
  Change all three in one diff. (A deliberate exception to one home per fact: the
  tests prove the tables, the spec is what a person reviews.)

## Verify
`bin/rails test packs/scoring test/boundaries_test.rb test/traceability_test.rb`
