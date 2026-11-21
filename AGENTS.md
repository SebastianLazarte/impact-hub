# Impact Hub: instructions for coding agents

Rails 8.1 modular monolith that scores departmental automation requests.
Spec: [docs/specs/](docs/specs/AGENTS.md) (system.md, one file per capability).
Acceptance criteria: [docs/requirements.yml](docs/requirements.yml).
Changes in progress: [docs/changes/](docs/changes/AGENTS.md).

## Hard rules (each one is enforced by a test or CI step)
Ids point at [docs/specs/system.md](docs/specs/system.md), the one home of these rules. They
are repeated here on purpose, so every session loads them without opening the spec.
1. Code computes every number; no LLM output becomes a number. (P1)
2. A control can only be raised, through `Scoring::Levels.stricter`. (P2)
3. Hours are BigDecimal; unknown is `nil` with a reason, never `0`. (P4)
4. `packs/scoring` depends on nothing. (C2, IH-7)

## Routing: read before you edit
| Area | Read first | Verify with |
|---|---|---|
| Who the users are, why the product exists | [docs/product/](docs/product/vision.md) (vision, personas, scenarios); sources in [research.md](docs/product/research.md) | a person; claims tagged `Evidence:` |
| Site surveys and barriers (change 001, in progress) | [change 001](docs/changes/001-site-survey-specification/proposal.md) (its spec delta) and [docs/product/](docs/product/vision.md) | until 001 merges, `docs/specs/` still describes the baseline and is the truth for the code |
| A behaviour change (new phase, new or changed IH-n) | [docs/changes/AGENTS.md](docs/changes/AGENTS.md) | the proposal's `Status: Approved`, then `bin/ci` |
| `packs/scoring/` | [packs/scoring/AGENTS.md](packs/scoring/AGENTS.md), [docs/specs/scoring.md](docs/specs/scoring.md) | the command in that file |
| `app/controllers`, `app/frontend` | C1 and Q1 in [docs/specs/system.md](docs/specs/system.md) | `bin/rails test test/controllers` and `npm run check` |
| `package.yml`, new pack | C2 in [docs/specs/system.md](docs/specs/system.md), [docs/_templates/pack/](docs/_templates/pack/AGENTS.md) | `bin/packwerk validate && bin/packwerk check` |
| `docs/requirements.yml` | [docs/specs/](docs/specs/AGENTS.md) (each capability lists its ids) | `bin/rails test test/traceability_test.rb` |

## How to work
- Spec first, then ADRs. A behaviour change is drafted as a change folder under
  `docs/changes/` and approved by a person before any design or code. ADRs come only
  in step 3 (design): each answers an item of `docs/specs/` on its `Answers:` line; a
  decision with no spec item goes back to the spec first. None exist yet.
- Test first. Add or update the test named after its criterion (`test "IH-n: ..."`),
  watch it fail, then write the code.
- Never weaken an existing assertion, skip a test or edit `requirements.yml` to make
  a test pass. If a test looks wrong, stop and say so.
- Keep diffs small and inside the task. No new gems or npm packages without asking.

## Commands
- Everything CI runs: `bin/ci`
- Tests: `bin/rails test test packs`
- Dev server (Rails + Vite): `bin/dev`, then http://localhost:3000

## Layout notes
- Method: product-sdlc: discover, then one change folder per behaviour change, eight
  checked steps ([docs/changes/AGENTS.md](docs/changes/AGENTS.md); spec C3).
- `AGENTS.md` is the entry file; `CLAUDE.md` only imports it. Edit `AGENTS.md`.
- Folder contracts are named `AGENTS.md` (not `CONTEXT.md`) so agents load them
  automatically when they work inside that folder.
- Templates live in `docs/_templates/`, following Rails layout rather than a root `_templates/`.
