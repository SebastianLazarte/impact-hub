# 001. Survey a site and specify a barrier for every hazard point: design

Status: Approved (2026-11-21, by Sebastian Lazarte)
<!-- Step 3. A person approves this design and its ADRs; then the ADRs become Accepted
     and the "Decided in" cells of specs/system.md link to them. -->

## Approach
The rules live in a pure-Ruby pack, the data in two Rails packs, and the pages in the
root app.

- **Showing a survey:** `SurveysController#show` calls `Surveys::AssessSurvey`. It loads
  the survey and its points, loads the current catalog barriers for the applications
  present, turns each point into an `Impact::HazardPoint`, and runs `Impact::Rules.assess`
  on it. An Alba page resource turns the result into props, with every number formatted
  as text, and Inertia renders the React page, whose prop types Typelizer generated from
  that resource. Nothing derived is stored ([ADR 0004](../../adr/0004-results-computed-when-shown.md)).
- **Creating a survey:** `SurveysController#create` calls `Surveys::CreateSurvey`. It
  validates the survey and all its points, saves them in one transaction, and returns
  either the survey or errors keyed by form field. The controller redirects to the survey
  page, or back to the form with the errors.

### Approaches considered
| Question | Chosen | Rejected, and why |
|---|---|---|
| How page data gets one definition (Q3) | **Alba + Typelizer**: a Ruby resource per page, TypeScript generated from it, CI fails if stale. Picked by Sebastian Lazarte on 2026-11-21: the team's own tooling (research R9), no home-grown generator to maintain. | Our own generator, about 150 lines and no new gems: rebuilds what Typelizer does. Hand-written types plus a JSON Schema check: two new packages and still two definitions. |
| When results are computed (Q1) | **Every time a page is shown**, nothing stored. | Store at save and recompute on change: needs change tracking and fails IH-25 the day one is missed. A cache keyed by catalog and rules version: premature for one survey page. |
| Shape of a use case (Q2) | **One plain Ruby class per action**, returning a small `Result`. | An interactor gem or dry-monads: new gems for a few lines of Ruby. Sorbet's typed `Result[T]` (R9): its own change if wanted. |
| How a page is tested | **Read the Inertia props** from the response, as the baseline does. Pages compute nothing (Q3), so the props are what the page shows. | Browser system tests: a headless browser in CI for little gain while pages only print props. The step 7 walk-through checks the screen. |

## Packs touched
| Pack | New or changed | Dependencies (package.yml) |
|---|---|---|
| `packs/impact` | new | none, `enforce_dependencies: strict` |
| `packs/catalog` | new | `packs/impact` |
| `packs/surveys` | new | `packs/impact`, `packs/catalog` |
| `.` (root, `app/`) | changed | `packs/impact`, `packs/catalog`, `packs/surveys` |
| `packs/scoring` | deleted, with its tests | — |

Why this split: [ADR 0003](../../adr/0003-three-packs-root-presents.md). Each new pack
gets `AGENTS.md`, `CLAUDE.md` and `package.yml` from `docs/_templates/pack/`.

### packs/impact (impact.md)
Pure Ruby, same style as the baseline's scoring pack: `Data.define` values validated
when built (a bad value raises `ArgumentError` there, not inside a rule).

- `Impact::Fact(value, source)`: `value` a `BigDecimal` or `nil`; `source` one of
  `:measured`, `:estimated`, `:declared`, or `nil`; a source exactly when there is a value.
- `Impact::HazardPoint(application, vehicle_mass_kg, max_load_kg, speed_kmh,
  impact_angle_deg, clearance_mm)`: `application` from `Impact::APPLICATIONS`, every
  other field an `Impact::Fact`, with the ranges of impact.md section 2. These lists and
  limits are constants here; the surveys pack validates against the same constants, so
  each limit is written once.
- `Impact::Barrier(name, application, deflection_mm, ratings)`: `ratings` maps a test
  angle (`BigDecimal`) to a tested energy (`Integer`, J).
- Results:
  - `Impact::Energy(joules, missing, unmeasured)`: `joules` an `Integer` or `nil`.
  - `Impact::Verdict(barrier, kind, rating, reason, unmeasured)`, where `rating` is an
    `Impact::Rating(angle_deg, joules)` or `nil` when the barrier is not rated.
  - `Impact::Assessment(energy, verdicts, outcome, reason, recommendation,
    other_fitting, unmeasured)`.
- `Impact::Rules.required_energy(point)`, `.verdict(point, energy, barrier)` and
  `.assess(point, barriers)`. `assess` keeps only the barriers of the point's application
  and computes verdicts only when the energy is known (impact.md section 5).
- A reason is a symbol or a verdict kind, plus the values the result already carries
  (for `too_weak`, the rating and the energy). The page resource writes the sentence.
  The rules write no prose and format no numbers.
- `unmeasured` follows impact.md section 2. For an energy: the facts among mass, load,
  speed and angle whose source is not `measured`. For a verdict or an outcome: those, plus
  the clearance when it has a value that was not measured.
- `Impact::Outcomes::ORDER = %i[specified needs_site_check engineering_review]`;
  `incomplete` is outside it. Nothing moves an outcome in 001, so a `stricter` method
  comes with the first change that does.
- Energy arithmetic: [ADR 0001](../../adr/0001-energy-exact-fractions-sine-upper-bound.md).

### packs/catalog (catalog.md)
- `Catalog::Barrier` (table `catalog_barriers`) has many `Catalog::BarrierRating`
  (table `catalog_barrier_ratings`).
- `Catalog.barriers_for(applications)` returns a hash from application to
  `[Impact::Barrier]`, in one query with the ratings preloaded.
- `Catalog::Seed.call`: idempotent; `db/seeds.rb` calls it. It is the only write path;
  nothing else writes to the catalog.
- `Catalog::NOTICE = "example values, not manufacturer data"`: the one home of the
  IH-22 text.

### packs/surveys (survey.md)
- `Surveys::Survey` (table `surveys`) has many `Surveys::HazardPoint` (table
  `hazard_points`), ordered by `position`. `HazardPoint#to_impact` builds the
  `Impact::HazardPoint`.
- Use cases ([ADR 0005](../../adr/0005-one-use-case-per-action.md)):
  - `Surveys::CreateSurvey.call(attributes)` returns a `Surveys::Result` (`success?`,
    `value`, `errors`).
  - `Surveys::AssessSurvey.call(survey_id)` returns a `Surveys::SurveyAssessment`
    (the survey, and for each point its record and its `Impact::Assessment`). It raises
    `ActiveRecord::RecordNotFound` for an unknown id, which Rails turns into a 404.
  - `Surveys::ListSurveys.call` returns the surveys with their point counts, latest
    survey date first, then latest created.

### Root app
- `SurveysController` (`index`, `new`, `create`, `show`). `HomeController`, its test
  and `pages/home/` are deleted.
- `app/resources/`: `ApplicationResource` (Alba, with `helper Typelizer::DSL`) and one
  page resource per page: `SurveyListPageResource`, `SurveyFormPageResource` and
  `SurveyPageResource`, each with its nested resources
  ([ADR 0006](../../adr/0006-page-data-alba-typelizer.md)).
- `app/frontend/pages/surveys/{index,new,show}.tsx`. Prop types are imported from
  `app/frontend/types/serializers/`, which is generated and committed.
- One formatting module for quantities, used by every resource: a thousands separator,
  the unit after a space, no trailing zeros ("4,000 kg", "8.05 km/h", "90°", "600 mm",
  "11,359 J"). Dates read "21 Nov 2026".
- Pages and forms: [ADR 0002](../../adr/0002-inertia-pages-thin-controllers.md).

## Data
One migration per pack. Numbers are PostgreSQL `numeric` with no precision or scale,
so a fact is stored exactly as typed and never rounded (P3). Model validations give
the plain-language messages (IH-21); the check constraints are a backstop.

| Table | Columns | Constraints |
|---|---|---|
| `catalog_barriers` | `name` string, `application` string, `deflection_mm` numeric, timestamps | all not null; `name` unique; `application` in the list; `deflection_mm >= 0` |
| `catalog_barrier_ratings` | `barrier_id`, `test_angle_deg` numeric, `energy_j` integer | all not null; foreign key; angle 1 to 90; energy > 0; unique (`barrier_id`, `test_angle_deg`) |
| `surveys` | `site_name`, `customer_name` string, `surveyed_on` date, `mode` string, `notes` text, timestamps | all but `notes` not null; `mode` in (`on_site`, `remote`) |
| `hazard_points` | `survey_id`, `position` integer, `name`, `zone`, `application` string; for each fact `f` in `vehicle_mass_kg`, `max_load_kg`, `speed_kmh`, `impact_angle_deg`, `clearance_mm`: `f` numeric and `f_source` string; timestamps | foreign key, delete cascade; unique (`survey_id`, `position`); `name`, `zone`, `application` not null; `application` in the list; `f_source` in (`measured`, `estimated`, `declared`); `f` is null exactly when `f_source` is null; mass > 0, load >= 0, speed > 0, angle 1 to 90, clearance >= 0 |

### Seeded catalog
Fictional. Every barrier is tested at 45° and 90°, with the 90° energy not above the
45° one (catalog.md section 3). Names are generic codes, so they imitate no product
(C4). The pedestrian and column rows are fixed because S1 and S3 depend on them; the
builder adds two or three barriers for each other application under the same rules.

| Name | Application | 45° | 90° | Deflection |
|---|---|---|---|---|
| PR-4 | pedestrian | 7,000 J | 4,000 J | 250 mm |
| PR-12 | pedestrian | 20,000 J | 12,000 J | 450 mm |
| PR-18 | pedestrian | 30,000 J | 18,000 J | 700 mm |
| PR-24 | pedestrian | 40,000 J | 24,000 J | 550 mm |
| CG-9 | column | 15,000 J | 9,000 J | 100 mm |
| CG-40 | column | 60,000 J | 40,000 J | 150 mm |

Tests that need the catalog call `Catalog::Seed.call`, so the seed is the one source of
catalog data; there are no catalog fixtures. Tests of the impact pack build
`Impact::Barrier` values inline.

## Interfaces
Routes:
```ruby
root "surveys#index"
resources :surveys, only: %i[index new create show]
```

Every page gets its props from one resource. These are the field names Typelizer will
emit; `Source`, `Application`, `Mode`, `Outcome` and `Verdict` are string-literal unions
built from the impact constants.

`surveys/index`, from `SurveyListPageResource`:
```ts
surveys: Array<{ id: number; site_name: string; customer_name: string;
  surveyed_on: string; mode: Mode; point_count: number }>
```

`surveys/new`, from `SurveyFormPageResource`. It sends the choice lists, so the form
hard-codes none of them:
```ts
modes: Array<{ value: Mode; label: string }>
applications: Array<{ value: Application; label: string }>
sources: Array<{ value: Source; label: string }>
facts: Array<{ key: FactKey; label: string; unit: string }>
```

`surveys/show`, from `SurveyPageResource`:
```ts
survey: { site_name: string; customer_name: string; surveyed_on: string;
  mode: Mode; notes: string | null }
catalog_notice: string            // IH-22, from Catalog::NOTICE
points: Array<{
  position: number; name: string; zone: string; application: string
  facts: Array<{ label: string; value: string | null; source: Source | null }>
  energy: { value: string | null; reason: string | null; unmeasured: string[] }
  outcome: { status: Outcome; label: string; reason: string | null; unmeasured: string[] }
  recommendation: string | null
  other_fitting: string[]
  barriers: Array<{ name: string; rating: string | null; deflection: string;
    verdict: Verdict; reason: string | null; unmeasured: string[] }>
}>
```
Each `unmeasured` entry reads like "maximum load (estimated)". `barriers` is empty
when the energy is unknown.

**Create.** `POST /surveys` with `survey: { site_name, customer_name, surveyed_on, mode,
notes, hazard_points: [{ name, zone, application, vehicle_mass_kg,
vehicle_mass_kg_source, … }] }`, in the order shown on the form. Positions are set
from that order, starting at 1.
- **Blank and unreadable values:** a blank value is unknown (`nil`). A value that is
  not a number (dot as the decimal mark, no thousands separator) fails with "Enter a
  number, like 8 or 8.5".
- **Success:** redirect to the survey page.
- **Failure:** `redirect_to new_survey_path, inertia: { errors: }`. Error keys are form
  field paths (`site_name`, `hazard_points.0.speed_kmh`, `hazard_points.0.speed_kmh_source`),
  plus `hazard_points` for "Add at least one hazard point", shown above the points.
  Inertia's `useForm` keeps what was typed.

**Messages (IH-21).** One plain sentence per field. Examples:
- "Enter the site name."
- "The angle must be between 1 and 90 degrees."
- "Speed must be above 0 km/h."
- "Choose where this value came from." (a value with no source)
- "Enter a value, or clear its source." (a source with no value)

**Reasons on the survey page.** Examples, one per verdict or outcome that has one:
- not rated: "not tested at 60° or steeper", or "its tested energy rises with the angle"
- too weak: "4,000 J is below 11,359 J"
- check space: "clearance not given"
- does not fit: "deflects 700 mm, 600 mm free"
- incomplete: "maximum load not given"
- engineering review: "no barrier rated high enough", or "the barriers that cover
  it do not fit the space"

## Prototype
List (`/`):
```
Surveys                                              [ New survey ]
Northgate DC     Acme Logistics     21 Nov 2026   on site   5 points
(empty: "No surveys yet. Start one with New survey.")
```

Form (`/surveys/new`). The source picker starts empty; nothing defaults to "measured" (P3).
```
New survey
Site [Northgate DC ]  Customer [Acme Logistics]  Date [2026-11-21]
Mode (•) on site  ( ) remote          Notes [                      ]

Hazard point 1                                                [ Remove ]
  Name [Aisle 4 walkway]   Zone [Aisle 4]   Application [Pedestrian ▾]
  Vehicle mass  [ 4000 ] kg    source [ measured ▾ ]
  Maximum load  [  600 ] kg    source [ estimated ▾ ]
  Speed         [    8 ] km/h  source [ declared ▾ ]
  Impact angle  [   90 ] °     source [ estimated ▾ ]
  Clearance     [  600 ] mm    source [ measured ▾ ]
[ + Add hazard point ]                                  [ Save survey ]
```

Survey page (`/surveys/:id`):
```
Northgate DC · Acme Logistics · 21 Nov 2026 · on site
Example values, not manufacturer data

1. Aisle 4 walkway · Aisle 4 · Pedestrian
   Vehicle mass 4,000 kg (measured) · Maximum load 600 kg (estimated)
   Speed 8 km/h (declared) · Impact angle 90° (estimated) · Clearance 600 mm (measured)

   Required energy 11,359 J
     rests on: maximum load (estimated), speed (declared), impact angle (estimated)
   SPECIFIED · Recommended: PR-12 · Also fits: PR-24

   Barrier  Rating            Deflection  Verdict
   PR-4     4,000 J at 90°    250 mm      too weak: 4,000 J is below 11,359 J
   PR-12    12,000 J at 90°   450 mm      fits
   PR-18    18,000 J at 90°   700 mm      does not fit: deflects 700 mm, 600 mm free
   PR-24    24,000 J at 90°   550 mm      fits

2. Bay 3 column · Loading bay · Column
   Required energy 83,334 J
   ENGINEERING REVIEW · no barrier rated high enough
   CG-9     9,000 J at 90°    100 mm      too weak: 9,000 J is below 83,334 J
   CG-40    40,000 J at 90°   150 mm      too weak: 40,000 J is below 83,334 J
```

## Scenario walk
**S1 (Nadia, Northgate DC).**
1. Nadia opens `/`, sees the empty list and chooses New survey.
2. She fills in the survey and the point "Aisle 4 walkway" as in the form sketch.
3. In 001 she enters the four other points on the same form, then saves.
4. The survey page shows 11,359 J and recommends PR-12, with PR-24 as also fitting.
   PR-18 is listed as not fitting, "deflects 700 mm, 600 mm free". This matches S1.

**Where it breaks:** S1 reads as if Nadia sees the result before adding the next
points. With one form, and editing out of scope, she sees results only after saving
all five. The proposal chose one form and left editing out, so the design keeps that.
Seeing results while entering is a later change; Inertia's server-side form
validation, already in `inertia_rails`, could carry it.

**S2 (remote, load unknown).** Nadia leaves the load blank with no source. The page
shows "Required energy unknown: maximum load not given", the outcome INCOMPLETE, and no
barrier table. She asks the customer one question.

**S3 (Nadia, Tomás, loading bay).** A column point with 12,000 + 3,000 kg at 12 km/h
and 90°. The page shows 83,334 J, both column guards too weak, and ENGINEERING REVIEW
with "no barrier rated high enough". Tomás sees the number and the reason.

## Non-functional
- **Security:** there is no authentication in 001 (out of scope in the spec), so anyone
  who can reach the app sees every survey. That is acceptable only while deploy is out
  of scope. Strong parameters, and Brakeman stays clean.
- **Reliability:** `CreateSurvey` saves the survey and its points in one transaction
  (IH-20, IH-21).
- **Performance:** `AssessSurvey` runs one query for the survey and its points, and one
  for the barriers and ratings of the applications present. The rules run in memory,
  which is fine for hundreds of points.
- **Precision:** [ADR 0001](../../adr/0001-energy-exact-fractions-sine-upper-bound.md).

## CI
- `config/ci.rb` and `.github/workflows/ci.yml` gain a step before "Types: TypeScript":
  `TYPELIZER=true bin/rails typelizer:types:refresh`. The step fails if anything under
  `app/frontend/types/serializers/` changed or appeared (`git status --porcelain`).
- `TYPELIZER=true` is required: Typelizer turns its DSL off outside development, and
  without it the generated types would lose every `typelize` annotation.
- In the workflow the step runs in the job that has the database, because the task
  boots the app.
- `test/boundaries_test.rb` points at `packs/impact` (IH-7).

## Tests
Several tests may name the same criterion (C3 needs at least one each).
| Criterion | Test file |
|---|---|
| IH-7 | `test/boundaries_test.rb` |
| IH-14 | `packs/impact/test/impact/energy_test.rb` (worked examples; upper-bound property, ADR 0001); `test/controllers/surveys_controller_test.rb` (energy shown as text) |
| IH-15 | `packs/impact/test/impact/energy_test.rb`; `packs/impact/test/impact/assessment_test.rb` (`incomplete`, no recommendation) |
| IH-16 | `packs/impact/test/impact/rating_test.rb` |
| IH-17 | `packs/impact/test/impact/verdict_test.rb` |
| IH-18, IH-19, IH-24 | `packs/impact/test/impact/assessment_test.rb` |
| IH-20, IH-21 | `packs/surveys/test/surveys/create_survey_test.rb` (no HTTP); `test/controllers/surveys_controller_test.rb` (redirect, error keys, list) |
| IH-22 | `test/controllers/surveys_controller_test.rb` (`catalog_notice` on the survey page) |
| IH-23 | `packs/impact/test/impact/assessment_test.rb` (`unmeasured` lists); `packs/surveys/test/surveys/create_survey_test.rb` (sources kept) |
| IH-25 | `packs/surveys/test/surveys/assess_survey_test.rb` (change a seeded barrier's deflection; the verdict follows) |
| Q2 | one test file per use case in `packs/surveys/test/surveys/` |
| Q3 | the CI step above, plus `npm run check` |

Removed with the baseline: `packs/scoring/test/`, and `test/controllers/home_controller_test.rb`
(IH-8).

## Risks
- **Typelizer and plain Ruby objects.** Typelizer infers nothing for a resource over a
  plain object, so every attribute needs `typelize`. An untyped one becomes `unknown`,
  which `tsc` rejects where a page uses it: a loud failure, not a silent one. The first
  build task generates one such resource and checks its output before any page is built
  on it.
- **Typelizer off in CI.** It turns itself off outside development; the CI step sets
  `TYPELIZER=true` (see CI).
- **`BigMath` behaviour across `bigdecimal` versions.** The upper-bound property test
  in ADR 0001 catches a change.
- **Form error keys.** Nested errors must match `useForm`'s field paths. The IH-21
  controller test asserts the keys.
- **No results while entering.** See the scenario walk; a later change.
- **Seed and tests share one source.** Changing the seed changes the S1 and S3 tests.
  That is intended.

## Calls made in this design
Made by Claude, for review. Each sits in its section above.
- Every number goes to a page as formatted text ("11,359 J"), and dates as "21 Nov 2026".
- Rules return reason codes; the page resources write the sentences.
- The form's source picker starts empty, with no default (P3).
- The seeded catalog values and the codes PR-n and CG-n.
- Tests check Inertia props, not the rendered screen.
- After a save, the redirect goes to the survey page.
- The list puts the latest survey date first.
- `Surveys::Result` lives in the surveys pack until a second pack needs it.
- No `listen` gem: types are regenerated by `bin/rails typelizer:types`, or by
  Typelizer's development middleware while `bin/dev` runs.
