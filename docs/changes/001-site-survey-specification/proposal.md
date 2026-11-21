# 001. Survey a site and specify a barrier for every hazard point

Status: Draft
Track: full
Owner: Sebastian Lazarte
<!-- Status: Draft -> Approved (YYYY-MM-DD, by <name>) -> Done (YYYY-MM-DD), or
     Abandoned (YYYY-MM-DD, reason) at any point. One line, edited in place. -->

## Why

### Problem statement
A safety surveyor like [Nadia](../../product/personas.md#nadia-safety-surveyor-sales-engineer)
needs to turn what is found on a site walk into a barrier specification that holds,
because each barrier has to absorb the energy of the vehicle that could hit it and fit
the space behind it. Today that means recalculating by hand whenever a fact changes,
and losing track of which facts were guessed
([S1](../../product/scenarios.md#s1-surveying-a-warehouse-with-forklifts-nadia),
[S2](../../product/scenarios.md#s2-a-remote-survey-with-gaps-nadia)). A safety manager
like [Tomás](../../product/personas.md#tomás-customer-health-and-safety-manager) needs
to see why each barrier was chosen, and which points no standard barrier can cover
([S3](../../product/scenarios.md#s3-a-hazard-no-standard-barrier-covers-nadia-tomás)).

This is the first change of **Impact Hub**, which replaces the Intake Hub domain
([vision](../../product/vision.md)). Intake Hub did not show the business of the team
this product is built for; barrier specification does
([research](../../product/research.md) R1, R3), and it rests on a deterministic
calculation (R2) of the same kind as the existing rules.

### Stories
- As a surveyor, I want to record each hazard point with the vehicle, load, speed, angle
  and space I found so that the required energy is computed for me. (S1)
- As a surveyor, I want a missing fact to stay visibly unknown so that I ask the
  customer instead of guessing. (S2)
- As a surveyor, I want only barriers that cover the energy and fit the space to be
  recommended so that the specification never under-protects. (S1)
- As a safety manager, I want points that no standard barrier covers to be flagged with
  the reason so that an engineer looks at them. (S3)

### Success measure
In a walk-through of scenarios S1 and S3, a person who has not seen the app creates a
survey with five hazard points in under 15 minutes without help. Every point then
shows either a recommended barrier or the reason it has none, and three energies
checked by hand match the page. Checked in step 7 as a usability walk-through, since
deploy is out of scope.

## Options considered
| Option | For | Against |
|---|---|---|
| One form for the survey and all its points (chosen) | One submit; saved together or not at all | Long form on a big site |
| Wizard: save the survey, then add points one by one | Short screens; good on a tablet | Partial surveys to handle; more states |
| Import points from a spreadsheet | Fast for large sites | The personas work on tablets during the walk |
| Energy calculator only, nothing saved | Smallest build | No record to check later; fails Tomás's need |
| Keep the Intake Hub domain | Phases 0 to 2 already built | Does not show the target team's business (R1, R3) |
| Do nothing | No cost | No product for the new domain |

## Scope
- In:
  - A pure-Ruby `impact` pack with the rules of [specs/impact.md](specs/impact.md). It replaces
    `packs/scoring`.
  - A read-only, fictional barrier catalog, seeded and labelled "example values, not
    manufacturer data".
  - One form to create a survey with its hazard points.
  - A list of surveys.
  - A page per survey that shows, for every point, the required energy, each barrier's
    verdict, the outcome and the recommendation.
  - The home page becomes the list of surveys.
  - Kept from Intake Hub: the `IH-n` prefix (so `test/traceability_test.rb` stays as it
    is), the method, and the rule that only the rules compute (now P4).
- Out:
  - Editing or deleting surveys (a later change).
  - Sensor impact events (phase 4).
  - Prices, quantities and a proposal per zone (phase 5).
  - CAD or PDF output.
  - Editing the catalog.
  - mph and lb.
  - Authentication.
  - LLM suggestions (phase 7).
  - Deploy.

## Spec delta
Each file in [specs/](specs/system.md) is complete, exactly as it will appear in
`docs/specs/`; diff it against the current file. Links inside are relative to
`docs/specs/`.

| File | Change | What and why |
|---|---|---|
| [specs/system.md](specs/system.md) | MODIFIED: title, sections 1 to 4 | Impact Hub replaces Intake Hub: new problem, users, hazards and hard rules, constraints, qualities and phases. Sections 5 and 6 unchanged. |
| [specs/impact.md](specs/impact.md) | ADDED | Hazard point and the source of each fact, required energy, barrier rating, verdict and outcome (IH-7, IH-14 to IH-19, IH-23). |
| [specs/survey.md](specs/survey.md) | ADDED | A survey and its hazard points (IH-20, IH-21). |
| [specs/catalog.md](specs/catalog.md) | ADDED | The barriers and their fictional, labelled data (IH-22). |
| `scoring.md` | REMOVED | Automation scoring belongs to Intake Hub, which this change replaces (see Why). IH-1 to IH-6 and IH-8 are removed below; `packs/scoring` and its tests are deleted in this change. |

The index `docs/specs/AGENTS.md` gains a row per added file and loses `scoring.md`.

Section 3 of system.md, against the current one:
- ADDED 3.1 Hazards H1 to H4: the hard rules now come from what could go wrong in this
  domain, not from Intake Hub.
- Hard rules rewritten, each naming the hazard it prevents: P1 never under-protect (was
  P2, now with rounding up), P2 never assume space (from the old P2), P3 never invent a
  fact (was P4, now with the source of each fact), P4 only the rules compute (was P1),
  P5 issued means frozen and explained (new), P6 a person signs what is doubtful (was
  P3, now only doubtful points).
- MOVED: no imitation, from a hard rule to constraint C4; it prevents no hazard.
- MODIFIED C1: same stack; the reason is now the team's own choices (R9), and IH-8
  no longer checks it.
- C2 and C3: unchanged.
- MODIFIED Q1: an open survey instead of an open request; issued ones follow P5.
- ADDED Q2 and Q3.

## Criteria delta

ADDED:
```yaml
IH-14: >-
  When a hazard point has its vehicle mass, maximum load, speed and impact angle, the
  system shall show its required energy as 1/2 x (mass + load) x (speed / 3.6 x
  sin(angle))^2 in joules, computed without intermediate rounding and rounded up to a
  whole joule.
IH-15: >-
  If a hazard point is missing its vehicle mass, maximum load, speed or impact angle,
  then the system shall show the required energy as unknown, name every missing fact,
  and recommend no barrier.
IH-16: >-
  The system shall rate a barrier for a hazard point by its tested energy at the
  smallest test angle not below the hazard's angle, and shall never show as covering a
  barrier that has no such angle or whose rating is below the required energy.
IH-17: >-
  If the clearance of a hazard point is unknown or smaller than a barrier's deflection
  at maximum energy, then the system shall not show that barrier as fitting and shall
  show the reason.
IH-18: >-
  If no barrier of the hazard point's application both covers its required energy and
  fits a known clearance, and none is waiting for a clearance, then the system shall
  mark the point for engineering review with the reason and recommend no barrier.
IH-19: >-
  When at least one barrier fits a hazard point, the system shall recommend the fitting
  barrier with the lowest rating (ties: smaller deflection, then name) and list the
  other fitting barriers.
IH-20: >-
  When the surveyor submits a survey with a site name, a customer name, a survey date
  and at least one hazard point, the system shall save the survey with its points in
  the order given and show it in the list of surveys.
IH-21: >-
  If a submitted survey has any invalid field (an angle outside 1 to 90 degrees, a
  mass or speed not above 0, a load or clearance below 0, an application outside the
  list, or a fact with a value and no source), then the system shall save nothing and show a plain-language message next
  to each invalid field.
IH-22: >-
  (product) The system shall show "example values, not manufacturer data" on every
  page that shows catalog values.
IH-23: >-
  The system shall keep, for every fact of a hazard point that has a value, whether it
  was measured, estimated or declared by the customer, and shall name next to every
  energy, verdict and outcome the facts it rests on that were not measured.
```

MODIFIED: IH-7.
- Old: "(organisational) The scoring pack shall depend on nothing: no other pack, no Rails, no database, no network, no LLM."
- New:
  ```yaml
  IH-7: >-
    (organisational) The impact pack shall depend on nothing: no other pack, no Rails,
    no database, no network, no LLM.
  ```
- Why: `packs/impact` takes over from `packs/scoring` as the pure rules pack (P4, C2). `test/boundaries_test.rb` points at the new pack.

REMOVED:
- IH-1 to IH-6, the automation scoring rules. They belong to the Intake Hub domain,
  which this change replaces (see Why). `packs/scoring` and its tests are deleted in this change.
- IH-8, the home page with sample steps. The home page becomes the list of surveys;
  showing numbers and unknowns is now covered by IH-14 and IH-15. Its test in
  `test/controllers/home_controller_test.rb` is deleted with `HomeController`.

## Decisions
None yet. ADRs and `design.md` are written in step 3, after this spec delta is
approved, each ADR answering one item of system.md section 3. Items that will need an
answer then: C1 (how pages are served), C2 (the packs and their dependencies), Q1 (when
values are computed and when they freeze), Q2 (one place per use case) and Q3 (one
definition of the data a page receives; it may need new gems, which need approval).

## Validation
- [x] Validity: every story comes from scenarios S1 to S3 and a persona's goal.
- [x] Consistency: IH-15 and IH-17 apply P3 and P2 (unknown is never 0 or "fits");
  IH-14, IH-16 and IH-18 apply P1; IH-23 applies P3. Every hard rule names a hazard and
  every hazard has a rule. Each outcome in [specs/impact.md](specs/impact.md) section 6 is reached by exactly one
  first-matching row.
- [x] Completeness: open questions 1 to 7 are answered; question 7 changed IH-14 and
  IH-21 and added IH-23.
- [x] Realism: Inertia + React and `BigMath` (from the `bigdecimal` gem) are already in
  the bundle. Whether Q3 needs new gems is a step 3 question.
- [x] Section 3: every item has a check and states a need, not a solution. The set is
  complete for this change (open question 6).
- [x] Verifiability: each criterion is one observable outcome that one named test can
  check; the tests are named in step 3.

## Open questions
<!-- Each must be answered before Status: Approved. -->
Answered on 2026-11-21 by Sebastian Lazarte:
1. Safety margin: none in the rule; the public source says ratings include one
   ([specs/impact.md](specs/impact.md) section 3).
2. Test angles in the example catalog: 45° and 90° ([specs/catalog.md](specs/catalog.md) section 3).
3. Units: km/h and kg only; mph and lb are a later change (specs/impact.md section 3).
4. Recommendation: the fitting barrier with the lowest rating, the others listed (IH-19
   as written).
5. Applications: a closed list of five (IH-21 as written); editing it is a later change.
6. Section 3: complete for this change. Security (who may see a customer's survey)
   becomes a requirement with the change that brings authentication.
7. Hard rules (asked again: the first set came from Intake Hub): derived from a hazard
   analysis. Serious hazards: insufficient barrier, barrier that does not fit, invented
   fact; plus traceability of inputs, rules and versions, people and dates. Every fact
   records its source; every doubt goes to the safe side (energy rounded up); an issued
   specification is frozen; only doubtful points (incomplete, not measured, engineering
   review) need a person's signature; an LLM only suggests. Result: system.md 3.1 and
   3.2, C4, IH-14 and IH-21 changed, IH-23 added.
