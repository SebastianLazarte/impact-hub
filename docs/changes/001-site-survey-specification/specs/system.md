# Impact Hub: system specification

Status: **Approved** (<date of step 4>)

## 1. Problem
Industrial sites mix people, racking and machinery with forklifts and other vehicles.
A safety barrier only protects if it absorbs the energy of the vehicle that could hit
it and fits the space behind it. A surveyor gathers the facts on a site walk (vehicles,
loads, speeds, impact angles, space), and today the energy and the choice of barrier
are worked out by hand, where a changed fact or a guessed value is easy to miss and
hard to check afterwards.

Impact Hub makes that specification explicit, computed by rules, and reviewable.
Background and sources: [product/research.md](../product/research.md).

## 2. Users
| Who | Needs | Uses the system from |
|---|---|---|
| Safety surveyor | Record hazard points on site or remotely, with the source of each fact; get the required energy and a barrier that covers it and fits | phase 3 |
| Safety engineer | Review the points that are incomplete, rest on facts that were not measured, or need engineering review; sign them, or specify a solution outside the catalog (P4, P6) | phase 5 |
| Customer safety manager | Read why each barrier was chosen and show it to an auditor; declare site facts that cannot be measured (until phase 5 the surveyor records them as `declared`) | phase 5 |

Personas and scenarios behind these users (assumptions until observed): [product/](../product/personas.md).

## 3. Principles and constraints
What must hold, not how. Each item says how it is checked. The hard rules come from the
hazards in 3.1. ADRs come later, in step 3 of a change: each answers one item here, and
the item's "Decided in" cell then links to it. Until then it reads "—".

### 3.1 Hazards
The worst outcomes Impact Hub could cause if it were wrong.
| Id | Hazard | Harm | Causes |
|---|---|---|---|
| H1 | **Insufficient barrier**: the recommended barrier cannot absorb the real impact | A person, a rack or a machine is left unprotected | Energy understated (rounding, angle, missing load); rating overstated; a rule, a person or an LLM choosing a weaker barrier |
| H2 | **Barrier that does not fit**: it deflects into what it protects | The impact reaches the protected person or asset | Clearance unknown or smaller than the deflection, treated as enough |
| H3 | **Invented fact**: a value nobody measured is treated as real | A result looks reliable and is not; nobody asks the customer | A default or `0` for a missing value; an estimate shown as a measurement |
| H4 | **Unexplainable or changed result**: nobody can say why a barrier was chosen, or the numbers change after delivery | A specification cannot be audited or defended; the customer loses trust | Values not reproducible; rules or catalog changed under an issued specification; no record of who decided |

### 3.2 Hard rules
| Id | Rule | Prevents | Checked by | Decided in |
|---|---|---|---|---|
| P1 | **Never under-protect.** No barrier is recommended whose rating at the point's angle is below the required energy. Every rounding and every doubt goes to the safe side: energy is rounded up, and a doubtful point goes to review, never to the closest fit. | H1 | IH-14, IH-16, IH-18 tests | [ADR 0001](../adr/0001-energy-exact-fractions-sine-upper-bound.md) |
| P2 | **Never assume space.** A barrier is shown as fitting only when the clearance is known and not smaller than its deflection. | H2 | IH-17, IH-24 tests | — |
| P3 | **Never invent a fact.** Every fact carries its source (measured, estimated, declared by the customer) or is unknown. An unknown is never replaced by a default or by `0`, and every result names the facts it rests on that were not measured. | H3 | IH-15, IH-23 tests | — |
| P4 | **Only the rules compute.** Energies, ratings, verdicts and recommendations are computed by the rules, reproducibly: the same facts with the same rules and catalog give the same result. A person or an LLM may propose facts, never a number, and never replaces a recommendation. The one exception is a point in engineering review: a named person may specify a solution outside the catalog and sign it (P6). | H1, H3, H4 | IH-14 to IH-19, IH-24 tests; review | — |
| P5 | **Issued means frozen and explained.** An issued specification keeps its facts with their sources, the versions of the rules and catalog, who surveyed, who signed and when, and never changes; new rules give a new version. | H4 | phase 5 criteria | — |
| P6 | **A person signs what is doubtful.** A point that is incomplete, rests on facts that were not measured, or needs engineering review is not issued without a named person's signature; everything else may be issued without one. | H1, H3 | phase 5 criteria | — |

### 3.3 Constraints
| Id | Constraint | Why | Checked by | Decided in |
|---|---|---|---|---|
| C1 | Ruby 3.4, Rails 8.1, PostgreSQL 17; pages in React + TypeScript served by Rails, with no separate JSON API | The stack of the team this product is built for ([research](../product/research.md) R9) | `bin/ci` | [ADR 0002](../adr/0002-inertia-pages-thin-controllers.md) |
| C2 | One deployable app in modules with enforced boundaries; the rules module depends on nothing | Rules stay testable alone and cannot reach a database, network or LLM | IH-7; `bin/packwerk check` | [ADR 0003](../adr/0003-three-packs-root-presents.md) |
| C3 | Every behaviour change is proposed, specified and approved by a person before code; every criterion is proven by one named test | Changes stay reviewable; nothing is built without a criterion | `test/traceability_test.rb`; review | — |
| C4 | **No imitation.** The product shows no manufacturer's name, logo, product names or data; the catalog is fictional and labelled | Real manufacturers' trademarks and data are theirs, and a portfolio product must not pass for one | IH-22 test; review | — |

### 3.4 Quality requirements
| Id | Requirement | Checked by | Decided in |
|---|---|---|---|
| Q1 | **Values follow the current rules until issued.** While a survey is open, its values follow the current rules and catalog; once a specification is issued (phase 5), P5 applies. | IH-25 test; phase 5 criteria | [ADR 0004](../adr/0004-results-computed-when-shown.md) |
| Q2 | **Same rules from every entry point.** Whatever creates or changes data (a page now, a sensor webhook in phase 4, an LLM tool in phase 7) applies the same validation and rules, and each use case can be tested without HTTP. | one test per use case; review | [ADR 0005](../adr/0005-one-use-case-per-action.md) |
| Q3 | **The screen cannot drift from the server.** Pages show numbers as text formatted on the server and compute none. The data a page receives has one definition, and a mismatch between server and page fails the build. | `bin/ci` | [ADR 0006](../adr/0006-page-data-alba-typelizer.md) |

## 4. Scope by phase
| # | Delivers | Done when |
|---|---|---|
| 0 | WSL2 Ubuntu, Ruby 3.4, Rails 8.1, PostgreSQL 17 | `rails -v` and `psql` work |
| 1 | Rails app, Inertia + React + TS + Vite, Packwerk, CI, AGENTS.md | A React page renders through Inertia; CI is green |
| 2 | `impact` pack ([impact.md](impact.md)): required energy and barrier match, test first | IH-7, IH-14 to IH-19, IH-24 green |
| 3 | `catalog` and `surveys` packs ([catalog.md](catalog.md), [survey.md](survey.md)): create and view a survey with its hazard points | IH-20 to IH-23, IH-25 green; S1 walk-through done |
| 4 | Impact events from sensors: a simulated device posts to a signed webhook; each event is stored once against a surveyed hazard point, and repeated hits flag the point for a site check | A replayed event is stored exactly once; the point shows its hits |
| 5 | Proposal per zone: quantities, prices, a person signs; a snapshot is kept when issued | An issued proposal shows the same numbers later |
| 6 | After-sales: installed barriers, inspections due, warranty validity; sensor hits open an inspection | Every installed barrier shows its next inspection |
| 7 | An LLM suggests hazard points from survey notes | The suggestion is shown and cannot lower protection |

**This iteration: change 001 (phases 2 and 3).** Out of scope now: authentication,
pricing, a real LLM, deploy.

## 5. Acceptance criteria
The ids and texts live in [`requirements.yml`](../requirements.yml); each capability file
lists the ids it owns ([index](AGENTS.md)). Each test names the criterion it proves
(`test "IH-3: ..."`), and `test/traceability_test.rb` fails if a criterion has no test
or a test names an unknown criterion.

## 6. Open questions for review
None for the whole product. Questions about a capability live in its file.
