# 001. Survey a site and specify a barrier for every hazard point

Status: Approved (2026-11-21, by Sebastian Lazarte)
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

This is the first change of **Impact Hub** ([vision](../../product/vision.md)). Barrier
specification rests on a deterministic calculation
([research](../../product/research.md) R2), of the same kind as the existing rules.

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
| Do nothing | No cost | Surveys stay worked out by hand |

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
  - Kept from the baseline: the `IH-n` prefix (so `test/traceability_test.rb` stays as it
    is), the method, and the rule that only the rules compute (now P4).
  - In step 4, every reference outside `docs/specs/` to a rule id whose meaning
    changes: the hard rules and routing table of the root `AGENTS.md` (P1, P2, P4,
    `Scoring::Levels.stricter`, `packs/scoring`) and the P4 note in
    `docs/_templates/change/design.md` (now P3).
- Out:
  - Editing or deleting surveys (a later change).
  - Several vehicles per hazard point (a later change; a point records the one with
    the highest energy).
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
| [specs/system.md](specs/system.md) | MODIFIED: sections 1 to 4 | Rewritten for site surveys and barriers: new problem, users, hazards and hard rules, constraints, qualities and phases. Sections 5 and 6 unchanged. |
| [specs/impact.md](specs/impact.md) | ADDED | Hazard point and the source of each fact, required energy, barrier rating, verdict and outcome (IH-7, IH-14 to IH-19, IH-23, IH-24). |
| [specs/survey.md](specs/survey.md) | ADDED | A survey and its hazard points, and values that follow the current catalog while it is open (IH-20, IH-21, IH-25). |
| [specs/catalog.md](specs/catalog.md) | ADDED | The barriers and their fictional, labelled data (IH-22). |
| `scoring.md` | REMOVED | Automation scoring was the baseline's sample rules; the impact rules replace them. IH-1 to IH-6 and IH-8 are removed below; `packs/scoring` and its tests are deleted in this change. |

The index `docs/specs/AGENTS.md` gains a row per added file and loses `scoring.md`.

Section 3 of system.md, against the current one:
- ADDED 3.1 Hazards H1 to H4: the hard rules now come from what could go wrong in this
  domain, not from the baseline's sample rules.
- Hard rules rewritten, each naming the hazard it prevents: P1 never under-protect (was
  P2, now with rounding up), P2 never assume space (from the old P2), P3 never invent a
  fact (was P4, now with the source of each fact), P4 only the rules compute (was P1,
  now naming the one barrier a person may choose: a signed solution outside the catalog
  for a point in engineering review), P5 issued means frozen and explained (new), P6 a
  person signs what is doubtful (was P3, now only doubtful points). The ids P1 to P4
  are reused with new meanings, so every reference to them outside `docs/specs/` is
  updated in step 4 (see Scope).
- MOVED: no imitation, from a hard rule to constraint C4; it prevents no hazard.
- MODIFIED C1: same stack; the reason is now the team's own choices (R9), and IH-8
  no longer checks it.
- C2 and C3: unchanged.
- MODIFIED Q1: an open survey instead of an open request; issued ones follow P5.
  Checked by IH-25 instead of a page test.
- ADDED Q2 and Q3.

## Criteria delta

ADDED:
```yaml
IH-14: >-
  When a hazard point has its vehicle mass, maximum load, speed and impact angle, the
  system shall show its required energy as 1/2 x (mass + load) x (speed / 3.6 x
  sin(angle))^2 in joules, rounded up to a whole joule, with any intermediate value
  that cannot be exact also rounded up, so that it is never below the exact value.
IH-15: >-
  If a hazard point is missing its vehicle mass, maximum load, speed or impact angle,
  then the system shall mark the point as incomplete, show the required energy as
  unknown, name every missing fact, and recommend no barrier.
IH-16: >-
  The system shall rate a barrier for a hazard point by its tested energy at the
  smallest test angle not below the hazard's angle, and shall never show as covering a
  barrier that has no such angle, whose tested energy is higher at a larger test angle
  than at a smaller one, or whose rating is below the required energy.
IH-17: >-
  If the clearance of a hazard point is unknown or smaller than a barrier's deflection
  at maximum energy, then the system shall not show that barrier as fitting and shall
  show the reason.
IH-18: >-
  If the required energy of a hazard point is known, no barrier of its application
  both covers it and fits a known clearance, and none is waiting for a clearance, then
  the system shall mark the point for engineering review with the reason and recommend
  no barrier.
IH-19: >-
  When at least one barrier fits a hazard point, the system shall recommend the fitting
  barrier with the lowest rating (ties: smaller deflection, then name) and list the
  other fitting barriers.
IH-20: >-
  When the surveyor submits a survey with a site name, a customer name, a survey date,
  a mode and at least one hazard point, the system shall save the survey with its
  points in the order given and show it in the list of surveys.
IH-21: >-
  If a submitted survey has no hazard point or any invalid field (a site name,
  customer name, survey date, mode, or a point's name, zone or application left blank;
  a number or date that cannot be read; an angle outside 1 to 90 degrees; a mass or
  speed not above 0; a load or clearance below 0; a mode or application outside its
  list; or a fact with a value and no source, or a source and no value), then the
  system shall save nothing and show a plain-language message next to each invalid
  field, or above the hazard points when there are none.
IH-22: >-
  (product) The system shall show "example values, not manufacturer data" on every
  page that shows catalog values.
IH-23: >-
  The system shall keep, for every fact of a hazard point that has a value, whether it
  was measured, estimated or declared by the customer, and shall name next to every
  energy, verdict and outcome the facts it rests on that were not measured: for an
  energy, its mass, load, speed and angle; for a verdict or outcome, those and the
  clearance when it has a value.
IH-24: >-
  If the clearance of a hazard point is unknown and at least one barrier of its
  application covers its required energy, then the system shall mark the point as
  needing a site check, with the reason that the clearance is not given, and recommend
  no barrier.
IH-25: >-
  While a survey is open, the system shall show the verdicts, outcome and
  recommendation of each of its points as computed from the current catalog, not from
  the catalog in force when the survey was saved.
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
- IH-1 to IH-6, the baseline's automation scoring rules; the impact rules replace them.
  `packs/scoring` and its tests are deleted in this change.
- IH-8, the home page with sample steps. The home page becomes the list of surveys;
  showing numbers and unknowns is now covered by IH-14 and IH-15. Its test in
  `test/controllers/home_controller_test.rb` is deleted with `HomeController`.

## Decisions
Design approved on 2026-11-21 by Sebastian Lazarte: [design.md](design.md). Each ADR
answers one item of system.md section 3:
- P1: [ADR 0001](../../adr/0001-energy-exact-fractions-sine-upper-bound.md), energy in
  exact fractions, with an upper bound for a sine that cannot be exact.
- C1: [ADR 0002](../../adr/0002-inertia-pages-thin-controllers.md), Inertia pages from
  thin controllers; forms with `useForm`.
- C2: [ADR 0003](../../adr/0003-three-packs-root-presents.md), packs `impact`, `catalog`
  and `surveys`; pages in the root app.
- Q1: [ADR 0004](../../adr/0004-results-computed-when-shown.md), results computed when
  shown, none stored.
- Q2: [ADR 0005](../../adr/0005-one-use-case-per-action.md), one plain Ruby use case per
  action.
- Q3: [ADR 0006](../../adr/0006-page-data-alba-typelizer.md), Alba resources with types
  generated by Typelizer; the gems `alba` and `typelizer` were approved on 2026-11-21.

## Validation
- [x] Validity: every story comes from scenarios S1 to S3 and a persona's goal.
- [x] Consistency: IH-15, IH-17 and IH-24 apply P3 and P2 (unknown is never 0 or
  "fits"); IH-14, IH-16 and IH-18 apply P1; IH-23 applies P3. Every hard rule names a hazard and
  every hazard has a rule. Each outcome in [specs/impact.md](specs/impact.md) section 6 is reached by exactly one
  first-matching row and named by exactly one criterion (IH-15, IH-19, IH-24, IH-18).
- [x] Completeness: open questions 1 to 7 are answered; question 7 changed IH-14 and
  IH-21 and added IH-23. The review of 2026-11-21 added IH-24 (the site-check outcome
  had no criterion), added the required fields to IH-20 and IH-21, made IH-16 refuse
  to rate a barrier whose tested energy rises with the angle, and clarified P4. A
  second review the same day made IH-15 name the `incomplete` outcome, limited IH-18
  to points whose required energy is known, and put `incomplete` outside the outcome
  order. It also made every rounding in IH-14 go up, since the sine of most angles
  cannot be exact, and dropped "exactly" from P4. It added IH-25, so that Q1 has a
  criterion, and stated that a point records one vehicle, the one with the highest
  energy, leaving several vehicles per point to a later change. IH-23 now says which
  facts each result rests on, IH-16 says plainly which barriers are not rated, IH-21
  also rejects a value that cannot be read and a source with no value, and the phase
  table in system.md section 4 lists IH-23 to IH-25.
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
7. Hard rules (asked again: the first set came from the baseline): derived from a hazard
   analysis. Serious hazards: insufficient barrier, barrier that does not fit, invented
   fact; plus traceability of inputs, rules and versions, people and dates. Every fact
   records its source; every doubt goes to the safe side (energy rounded up); an issued
   specification is frozen; only doubtful points (incomplete, not measured, engineering
   review) need a person's signature; an LLM only suggests. Result: system.md 3.1 and
   3.2, C4, IH-14 and IH-21 changed, IH-23 added.
