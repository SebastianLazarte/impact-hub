# packs/surveys

Surveys with their hazard points, saved together or not at all, and the use cases that act on them.
Spec: [docs/specs/survey.md](../../docs/specs/survey.md). Boundaries: C2 in [docs/specs/system.md](../../docs/specs/system.md).

## Rules
- Depends on: `packs/impact`, `packs/catalog`, declared in `package.yml`. Nothing else.
- One use case per action, returning a `Surveys::Result` ([ADR 0005](../../docs/adr/0005-one-use-case-per-action.md)).
- Never invent a fact: an unknown stays `nil` with no source, and text that is not a number is an error, never a stored 0 (P3, IH-21, IH-23, [create_survey_test.rb](test/surveys/create_survey_test.rb)).
- Limits and lists come from the impact pack's constants, never repeated here.

## Verify
`bin/rails test packs/surveys test/traceability_test.rb && bin/packwerk check`
