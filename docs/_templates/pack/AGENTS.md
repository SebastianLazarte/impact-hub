# packs/<name>

<!-- Template. Copy this folder to packs/<name>/ together with CLAUDE.md and package.yml;
     the relative links below resolve from there, not from docs/_templates/. -->

<One sentence: what this pack does.>
Spec: [docs/specs/<capability>.md](../../docs/specs/AGENTS.md). Boundaries: C2 in [docs/specs/system.md](../../docs/specs/system.md).

## Rules
- Depends on: <packs>, declared in `package.yml`. Nothing else.
- <The invariants this pack must keep, each with the spec id and the test that enforces it.>

## Verify
`bin/rails test packs/<name> test/traceability_test.rb && bin/packwerk check`
