# Impact Hub

From a site survey to a barrier specification that holds.

Industrial sites mix people, racking and machinery with forklifts. A safety barrier only
protects if it absorbs the energy of the vehicle that could hit it and fits the space
behind it. Impact Hub records the hazard points found on a site walk, computes the
impact energy of each one, and recommends only barriers that cover it and fit.

This repository is built spec first: every behaviour is specified and approved before
any design or code, and every acceptance criterion is proven by a test that names it.

## Where it stands
| Part | State |
|---|---|
| Rails 8.1 baseline: pure-Ruby rules pack, Inertia + React page, Packwerk boundaries, CI | built, CI green |
| [Change 001](docs/changes/001-site-survey-specification/proposal.md): survey a site and specify a barrier for every hazard point | specified, approved 2026-11-21 |
| [Design](docs/changes/001-site-survey-specification/design.md) and [ADRs 0001 to 0006](docs/adr/) for change 001 | approved 2026-11-21; next: merge the spec (step 4), then build |

The code on `main` is still the baseline described in [docs/specs/](docs/specs/AGENTS.md):
a sample rules pack behind one Inertia page. Change 001 replaces it with the site
survey. Until its spec is merged into `docs/specs/` (step 4), `docs/specs/` is the
truth for the code and the change folder is the proposal.

## What change 001 specifies
- **Required energy** per hazard point: `E = ½ × (mass + load) × (speed × sin(angle))²`,
  every rounding goes up, so it is never understated.
- **A barrier is recommended only if** its tested rating at the hazard's angle covers
  that energy and its deflection fits a known clearance. Otherwise the point says why:
  incomplete, needs a site check, or needs engineering review.
- **Hard rules derived from a hazard analysis**: never under-protect, never assume
  space, never invent a fact (every fact records whether it was measured, estimated or
  declared), only the rules compute, an issued specification is frozen, and a person
  signs what is doubtful.

The barrier catalog is fictional: example values, not manufacturer data.

## How the work flows
```
docs/product/     why and for whom: vision, personas, scenarios, desk research
docs/specs/       what the system does today: system.md + one file per capability
docs/changes/     one folder per proposed change: proposal, spec files, EARS criteria
docs/requirements.yml   acceptance criteria IH-n, each proven by a named test
AGENTS.md         entry point and hard rules for coding agents
```
A change goes through eight checked steps: propose, specify, design, merge spec, build,
review, release, archive ([docs/changes/AGENTS.md](docs/changes/AGENTS.md)). An ADR is
written only in the design step, to answer one item of the spec.

## Quality gates
- Every acceptance criterion has a test and every test names a criterion (`test/traceability_test.rb`).
- Decision tables are tested exhaustively, not by a few examples.
- Packwerk enforces pack boundaries; `test/boundaries_test.rb` keeps Rails, the database and LLMs out of the rules pack.
- RuboCop, Brakeman, bundler-audit and TypeScript run in CI (`bin/ci` runs the same steps locally).

## Stack
Rails 8.1 · Ruby 3.4 · PostgreSQL 17 · Inertia.js + React 19 + TypeScript + Vite ·
Tailwind · Packwerk · Solid Queue · Minitest · GitHub Actions

## Run it
```bash
bin/setup          # gems, npm packages, database
bin/dev            # Rails + Vite on http://localhost:3000
bin/ci             # every CI gate locally
```

## Roadmap
| Phase | Delivers | Status |
|---|---|---|
| 0-1 | Environment, Rails + Inertia + React, Packwerk, CI, docs | done |
| 2 | `impact` pack: required energy and barrier match, test first | specified (change 001) |
| 3 | `catalog` and `surveys` packs: create and view a survey with its hazard points | specified (change 001) |
| 4 | Impact events from sensors through a signed webhook | planned |
| 5 | Proposal per zone: quantities, prices, a person signs; frozen when issued | planned |
| 6 | After-sales: installed barriers, inspections due, warranty validity | planned |
| 7 | An LLM suggests hazard points from survey notes; it never computes or chooses | planned |
