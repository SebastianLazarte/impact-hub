# 001. Site survey and barrier specification: implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the baseline scoring sample with the site survey. A surveyor records
hazard points with the source of each fact; the app computes each point's required
energy, checks every catalog barrier of its application, and shows the outcome and the
recommended barrier.

**Architecture:** A pure-Ruby rules pack (`packs/impact`), a read-only seeded catalog
(`packs/catalog`) and the surveys pack (`packs/surveys`), with use cases. Pages are
Inertia React pages in the root app. Each page's data comes from one Alba resource,
whose TypeScript type Typelizer generates. Nothing derived is stored.

**Tech Stack:**
- Ruby 3.4, Rails 8.1, PostgreSQL 17, Minitest, Packwerk with packs-rails
- Inertia 3, React 19, TypeScript 7, Vite 8, Tailwind 4
- New: `alba` ~> 4.0, `typelizer` ~> 0.15 (approved 2026-11-21)

**Spec:**
- Behaviour: [proposal.md](proposal.md) (criteria IH-7 and IH-14 to IH-25) and
  [specs/](specs/system.md)
- How: [design.md](design.md) and ADRs [0001](../../adr/0001-energy-exact-fractions-sine-upper-bound.md)
  to [0006](../../adr/0006-page-data-alba-typelizer.md)

Read the design before any task; this plan does not repeat it.

## Global Constraints
- **Before Task 1:** the working tree is clean. Everything up to the approved design
  is committed.
- **Packages:** no gems beyond `alba` and `typelizer`, and no npm packages.
- **Pure pack:** `packs/impact` references no Rails, ActiveRecord, HTTP or LLM constant,
  and declares no dependencies (IH-7, C2).
- **Unknown values:** unknown is `nil`, with the missing facts named; never `0`,
  never a default (P3).
- **Numbers on pages:** every number reaches a page as a formatted string. Pages do no
  arithmetic and format no numbers (Q3).
- **Test names:** a test that proves a criterion is named `test "IH-n: …"`. Never weaken
  an assertion, skip a test, or edit `docs/requirements.yml` to make a test pass.
- **Catalog notice:** exactly `example values, not manufacturer data`.
- **No real products:** no manufacturer names, logos or product names anywhere (C4).
- **Commits:** every commit message ends with
  `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- **Verification commands:** `bin/rails test test packs` for all tests,
  `bin/packwerk validate && bin/packwerk check` for boundaries, `npm run check` for
  types, and `bin/ci` for everything.

## Review Focus
- **Text in a number field.** "abc", "4,000" or "8,5" in a fact gives "Enter a number,
  like 8 or 8.5." The value is never stored as 0, 4 or 8: Rails' decimal cast would do
  that silently. Test: Task 7.
- **Only spaces in a required text field.** "   " as the site name counts as blank:
  "Enter the site name." Test: Task 7.
- **Exact boundaries.** A rating equal to the required energy covers it. A deflection
  equal to the clearance fits (P1, P2 say "below" and "smaller"). Test: Task 4.
- **Angles typed with decimals.** "90.0" or "45.00" uses the exact sin² path and gives
  the same joules as 90 or 45. Test: Task 3.
- **Unknown survey id.** `/surveys/999999` is a 404, not a 500. Test: Task 10.

---

### Task 1: Merge the spec (step 4) and remove the baseline

**Files:**
- **Spec files:**
  - Replace `docs/specs/system.md` with `docs/changes/001-site-survey-specification/specs/system.md`.
  - Create `docs/specs/impact.md`, `docs/specs/survey.md` and `docs/specs/catalog.md`,
    copied from the change folder.
  - Delete `docs/specs/scoring.md`.
- **Other docs to modify:** `docs/specs/AGENTS.md`, `docs/requirements.yml`, `AGENTS.md`,
  `docs/_templates/change/design.md`.
- **Create** `docs/changes/001-site-survey-specification/tasks.md`.
- **Baseline code to delete:** `packs/scoring/`, `app/controllers/home_controller.rb`,
  `test/controllers/home_controller_test.rb`, `app/frontend/pages/home/`.
- **Code to modify:** `config/routes.rb`, `package.yml`, `test/boundaries_test.rb`.

**Interfaces:**
- Produces: the criteria IH-7 and IH-14 to IH-25 in `docs/requirements.yml`, which
  every later task's tests name.

- [ ] **Step 1: Copy the spec files word for word.**
  In each copied file, replace `<date of step 4>` with today's date, and change
  nothing else.

- [ ] **Step 2: Update `docs/specs/AGENTS.md`**
  - Rows:
    - `system.md`: `P1 to P6, C1 to C4, Q1 to Q3`
    - `impact.md`: required energy and barrier match, `packs/impact`, `IH-7, IH-14 to IH-19, IH-23, IH-24`
    - `survey.md`: a survey and its hazard points, `packs/surveys`, `IH-20, IH-21, IH-25`
    - `catalog.md`: the barriers and their fictional data, `packs/catalog`, `IH-22`
  - Remove the `scoring.md` row.
  - Replace the bullet "No ADRs exist yet. …" with: "ADRs live in [docs/adr/](../adr/).
    Each answers one item here on its `Answers:` line, and the item's "Decided in" cell
    links back. They are written in step 3 of a change, never before."

- [ ] **Step 3: Update `docs/requirements.yml`**
  - Delete IH-1 to IH-6 and IH-8.
  - Replace IH-7 with the new text from the proposal.
  - Append the proposal's ADDED block (IH-14 to IH-25) word for word.

- [ ] **Step 4: Update the step 4 references the proposal's Scope lists**

  In `AGENTS.md`, line 3 becomes: "Rails 8.1 modular monolith that turns a site survey
  into a barrier specification." The hard rules become:
  ```
  1. Never under-protect: energy is rounded up, and no barrier rated below it is recommended. (P1)
  2. Never assume space: a barrier fits only when the clearance is known and not below its deflection. (P2)
  3. Never invent a fact: unknown is `nil` with the missing facts named, never `0`; every value has a source. (P3)
  4. Only the rules compute: pages and LLMs compute no number. (P4, Q3)
  5. `packs/impact` depends on nothing. (C2, IH-7)
  ```
  Routing table:
  - The `packs/scoring/` row becomes `packs/impact/`, `packs/catalog/`, `packs/surveys/`
    | the pack's `AGENTS.md` and its spec in docs/specs/ | the command in that `AGENTS.md`.
  - The change 001 row's last cell becomes "`docs/specs/` is the truth; the change
    folder records how and why".
  - The `app/controllers` row reads "C1 and Q3 in system.md, ADRs 0002 and 0006", and
    adds `TYPELIZER=true bin/rails typelizer:types` to its checks.

  In `docs/_templates/change/design.md`, "(P4)" becomes "(P3)".

- [ ] **Step 5: Write `tasks.md` from the template.** Add one Build line per criterion,
  using the Tests table in design.md, for example
  `- [ ] IH-14: required energy, rounded up. Test: packs/impact/test/impact/energy_test.rb`.

- [ ] **Step 6: Remove the baseline**
  - Delete the files listed above.
  - In `config/routes.rb`, remove `root "home#index"`. Task 10 adds the new root.
  - In `package.yml`, set the root's dependencies to `[]`, and update its comment.
  - In `test/boundaries_test.rb`, the constant becomes
    `IMPACT = Rails.root.join("packs/impact")`. The two tests become
    `"IH-7: impact code references no Rails, database, network or LLM constant"` and
    `"IH-7: the impact pack declares no dependencies and enforces it strictly"`, with
    the same assertions.

- [ ] **Step 7: Run the step 4 check**

  Run: `bin/rails test test/traceability_test.rb`

  Expected: "every acceptance criterion has at least one test" FAILS, listing exactly
  `IH-14` to `IH-25`. "every test id names a real acceptance criterion" PASSES.
  `bin/rails test test/boundaries_test.rb` fails, because `packs/impact/package.yml`
  doesn't exist yet. That is expected; it goes green in Task 2.

- [ ] **Step 8: Commit**
  ```bash
  git add -A docs AGENTS.md config/routes.rb package.yml test app packs
  git commit -m "Merge change 001 spec into docs/specs and remove the baseline sample"
  ```

---

### Task 2: Impact pack and its values

**Files:**
- Create from `docs/_templates/pack/`: `packs/impact/package.yml`
  (`enforce_dependencies: strict`, `dependencies: []`), `packs/impact/AGENTS.md`,
  `packs/impact/CLAUDE.md`
- Create:
  - `packs/impact/app/services/impact.rb`
  - `packs/impact/app/services/impact/fact.rb`
  - `packs/impact/app/services/impact/hazard_point.rb`
  - `packs/impact/app/services/impact/barrier.rb`
- Test: `packs/impact/test/impact/hazard_point_test.rb`, `test/boundaries_test.rb` (now passes)
- Test support: `packs/impact/test/support/impact_helpers.rb`, module `ImpactHelpers`,
  which every impact test requires and includes. Task 4 adds to it.

**Interfaces:**
- Produces:
  - `Impact::APPLICATIONS = %i[pedestrian traffic rack_end column machine]`
  - `Impact::SOURCES = %i[measured estimated declared]`
  - `Impact::FACTS`: a frozen Hash, fact key → `{ label:, unit: }`:
    - `vehicle_mass_kg` → "vehicle mass", "kg"
    - `max_load_kg` → "maximum load", "kg"
    - `speed_kmh` → "speed", "km/h"
    - `impact_angle_deg` → "impact angle", "°"
    - `clearance_mm` → "clearance", "mm"
  - `Impact::ENERGY_FACTS = %i[vehicle_mass_kg max_load_kg speed_kmh impact_angle_deg]`
  - `Impact.out_of_range(fact, value) -> String | nil`: the message for a known value
    outside its range, else `nil`:
    - mass ≤ 0: "Vehicle mass must be above 0 kg."
    - load < 0: "Maximum load cannot be below 0 kg."
    - speed ≤ 0: "Speed must be above 0 km/h."
    - angle outside 1..90: "The angle must be between 1 and 90 degrees."
    - clearance < 0: "Clearance cannot be below 0 mm."
  - `Impact::Fact` (`Data`: `value`, `source`):
    - `Fact.unknown`; `#known?`; `#measured?`
    - `value` becomes a `BigDecimal` (String, Integer or BigDecimal in) and `source` a
      Symbol.
    - Raises `ArgumentError` for a value without a source, a source without a value,
      or a source outside `SOURCES`.
  - `Impact::HazardPoint` (`Data`: `application`, then the `FACTS` keys, each an
    `Impact::Fact`). Raises `ArgumentError` for an application outside `APPLICATIONS`,
    or any known value for which `out_of_range` returns a message.
  - `Impact::Barrier` (`Data`: `name`, `application`, `deflection_mm` BigDecimal,
    `ratings`, a frozen Hash from test angle BigDecimal to energy Integer).

- [ ] **Step 1: Write the failing tests**
  ```ruby
  test "a fact with a value needs a source, and a source needs a value" do
    assert_raises(ArgumentError) { Impact::Fact.new(value: "8", source: nil) }
    assert_raises(ArgumentError) { Impact::Fact.new(value: nil, source: :measured) }
    assert_equal BigDecimal("8.05"), Impact::Fact.new(value: "8.05", source: "estimated").value
  end

  test "a hazard point rejects an angle outside 1 to 90 and an unknown application" do
    assert_raises(ArgumentError) { point(impact_angle_deg: fact("0")) }
    assert_raises(ArgumentError) { point(application: :wall) }
  end

  test "out_of_range names the limit in plain language" do
    assert_equal "Speed must be above 0 km/h.", Impact.out_of_range(:speed_kmh, BigDecimal("0"))
    assert_nil Impact.out_of_range(:max_load_kg, BigDecimal("0"))
  end
  ```
  `ImpactHelpers` provides two helpers. `point(**overrides)` builds a valid pedestrian
  point (4000 kg, 600 kg, 8 km/h, 90°, 600 mm, all measured). `fact(value, source = :measured)`
  builds a Fact.

- [ ] **Step 2:** Run `bin/rails test packs/impact test/boundaries_test.rb`.
  Expected: FAIL (`uninitialized constant Impact`, missing `package.yml`).
- [ ] **Step 3:** Implement the interfaces above. In `packs/impact/AGENTS.md`, the
  rules list the invariants: no Rails constants (IH-7), unknown is `Fact.unknown`, and
  energy arithmetic follows ADR 0001. The Verify line is
  `bin/rails test packs/impact test/boundaries_test.rb test/traceability_test.rb && bin/packwerk check`.
- [ ] **Step 4:** Run the same command. Expected: PASS, including both IH-7 tests.
- [ ] **Step 5:** Commit: "Add the impact pack values".

---

### Task 3: Required energy (ADR 0001)

**Files:**
- Create: `packs/impact/app/services/impact/energy.rb`, `packs/impact/app/services/impact/rules.rb`
- Test: `packs/impact/test/impact/energy_test.rb`

**Interfaces:**
- Consumes: `Impact::HazardPoint`, `Impact::ENERGY_FACTS` (Task 2)
- Produces:
  - `Impact::Energy` (`Data`: `joules` Integer or nil, `missing` [fact keys in
    `ENERGY_FACTS` order], `unmeasured` [energy fact keys with a value whose source is
    not `:measured`]); `#known?`
  - `Impact::Rules.required_energy(point) -> Impact::Energy`
  - `Impact::Rules::DIGITS = 50`, `Impact::Rules::MARGIN = BigDecimal("1e-40")`

- [ ] **Step 1: Write the failing tests**
  ```ruby
  test "IH-14: the worked examples of impact.md section 3" do
    assert_equal 11_501, joules(mass: "4000", load: "600", speed: "8.05", angle: "90")
    assert_equal 11_359, joules(mass: "4000", load: "600", speed: "8", angle: "90")
    assert_equal 5_680, joules(mass: "4000", load: "600", speed: "8", angle: "45")
    assert_equal 83_334, joules(mass: "12000", load: "3000", speed: "12", angle: "90")
  end

  test "IH-14: exact angles typed with decimals use the exact sine" do
    assert_equal 11_359, joules(mass: "4000", load: "600", speed: "8", angle: "90.0")
    assert_equal 8_519, joules(mass: "4000", load: "600", speed: "8", angle: "60")
    assert_equal 2_840, joules(mass: "4000", load: "600", speed: "8", angle: "30.00")
  end

  test "IH-14: never below the exact value, at most 1 J above, at every half degree" do
    (BigDecimal("1")..BigDecimal("89.5")).step(BigDecimal("0.5")).each do |angle|
      next if [30, 45, 60].include?(angle)
      exact = reference_energy(4600, 8, angle) # 100-digit BigMath, no margin, as a Rational
      got = joules(mass: "4000", load: "600", speed: "8", angle: angle.to_s)
      assert_operator got, :>=, exact, "angle #{angle}"
      assert_operator got, :<, exact + 2, "angle #{angle}"
    end
  end

  test "IH-15: a missing fact makes the energy unknown and is named" do
    energy = Impact::Rules.required_energy(point(max_load_kg: Impact::Fact.unknown))
    assert_nil energy.joules
    assert_equal [ :max_load_kg ], energy.missing
  end

  test "IH-23: the energy names the facts it rests on that were not measured" do
    energy = Impact::Rules.required_energy(
      point(max_load_kg: fact("600", :estimated), speed_kmh: fact("8", :declared), clearance_mm: fact("600", :estimated))
    )
    assert_equal %i[max_load_kg speed_kmh], energy.unmeasured
  end
  ```

- [ ] **Step 2:** Run `bin/rails test packs/impact/test/impact/energy_test.rb`.
  Expected: FAIL (`uninitialized constant Impact::Rules`).
- [ ] **Step 3: Implement `Impact::Rules.required_energy`** as ADR 0001 states.
  The algorithm, because the signature doesn't fix it:
  ```ruby
  EXACT_SIN2 = { 30 => Rational(1, 4), 45 => Rational(1, 2), 60 => Rational(3, 4), 90 => Rational(1) }
  # sin² of the angle, exact where it can be, else an upper bound
  exact = EXACT_SIN2.find { |deg, _| angle == deg }&.last   # == so 90.0 matches 90
  s = [ BigMath.sin(angle * BigMath.PI(DIGITS) / 180, DIGITS) + MARGIN, 1 ].min unless exact
  sin2 = exact || s.to_r**2
  joules = ((mass + load).to_r * (speed.to_r / Rational(36, 10))**2 * sin2 / 2).ceil
  ```
- [ ] **Step 4:** Run the test file. Expected: PASS.
- [ ] **Step 5:** Commit: "Compute required energy, never below the exact value".

---

### Task 4: Rating and verdict per barrier

**Files:**
- Create: `packs/impact/app/services/impact/rating.rb`, `packs/impact/app/services/impact/verdict.rb`
- Modify: `packs/impact/app/services/impact/rules.rb`
- Test: `packs/impact/test/impact/rating_test.rb`, `packs/impact/test/impact/verdict_test.rb`

**Interfaces:**
- Consumes: `Impact::Barrier`, `Impact::Energy`, `Impact::Rules.required_energy`
- Produces:
  - `Impact::Rating` (`Data`: `angle_deg` BigDecimal, `joules` Integer)
  - `Impact::Rules.rating(barrier, angle_deg) -> Impact::Rating | nil`: `nil` when the
    barrier is not rated (impact.md section 4).
  - `Impact::VERDICTS = %i[not_rated too_weak check_space does_not_fit fits]`
  - `Impact::Verdict` (`Data`: `barrier`, `kind`, `rating` (`Impact::Rating` or nil),
    `reason`, `unmeasured`):
    - `reason` is `:no_test_angle` or `:rises_with_angle` for `not_rated`, else `nil`.
    - `unmeasured` is the energy's list, plus `:clearance_mm` when the clearance has a
      value that wasn't measured.
  - `Impact::Rules.verdict(point, energy, barrier) -> Impact::Verdict`, called only
    with a known energy. The first matching row of impact.md section 5 wins.

- [ ] **Step 1: Write the failing tests.** Add to `ImpactHelpers`:
  - `barrier(name, e45, e90, deflection)`: a pedestrian barrier tested at 45° and 90°
  - `column(...)`: the same for a column barrier
  - `s1_barriers`: PR-4, PR-12, PR-18 and PR-24, with the design's seeded values
  - `kind(barrier, **point_overrides)` and `verdict(...)`: run the verdict for the S1
    point and its known energy
  - `assess(point, barriers)`: calls `Impact::Rules.assess`
  ```ruby
  # rating_test.rb
  test "IH-16: the rating is the tested energy at the smallest test angle not below the hazard's" do
    b = barrier("B", 20_000, 10_000, 450)
    assert_equal [ BigDecimal("45"), 20_000 ], Impact::Rules.rating(b, BigDecimal("30")).to_h.values
    assert_equal [ BigDecimal("90"), 10_000 ], Impact::Rules.rating(b, BigDecimal("60")).to_h.values
  end

  test "IH-16: no rating without a test angle at or above the hazard's, or when energy rises with the angle" do
    only45 = Impact::Barrier.new(name: "A", application: :pedestrian, deflection_mm: BigDecimal("1"), ratings: { BigDecimal("45") => 9_000 })
    assert_nil Impact::Rules.rating(only45, BigDecimal("60"))
    assert_nil Impact::Rules.rating(barrier("R", 10_000, 20_000, 450), BigDecimal("30"))
  end

  # verdict_test.rb: S1 point, 11,359 J, clearance 600 mm measured
  test "IH-16: a barrier rated below the required energy is too weak, and equal is enough" do
    assert_equal :too_weak, kind(barrier("PR-4", 7_000, 4_000, 250))
    assert_equal :fits, kind(barrier("EQ", 20_000, 11_359, 450))
  end

  test "IH-17: unknown clearance, or a deflection above it, never fits" do
    assert_equal :does_not_fit, kind(barrier("PR-18", 30_000, 18_000, 700))
    assert_equal :fits, kind(barrier("EDGE", 30_000, 18_000, 600))
    assert_equal :check_space, kind(barrier("PR-12", 20_000, 12_000, 450), clearance_mm: Impact::Fact.unknown)
  end

  test "IH-23: a verdict names the clearance too when it was not measured" do
    v = verdict(barrier("PR-12", 20_000, 12_000, 450), clearance_mm: fact("600", :estimated))
    assert_includes v.unmeasured, :clearance_mm
  end
  ```
- [ ] **Step 2:** Run `bin/rails test packs/impact/test/impact/rating_test.rb packs/impact/test/impact/verdict_test.rb`.
  Expected: FAIL.
- [ ] **Step 3:** Implement `rating` and `verdict`. "Rises with the angle" means any
  larger test angle has a higher energy than a smaller one.
- [ ] **Step 4:** Run the tests. Expected: PASS.
- [ ] **Step 5:** Commit: "Rate barriers at the hazard angle and give a verdict".

---

### Task 5: Outcome and recommendation per point

**Files:**
- Create: `packs/impact/app/services/impact/assessment.rb`, `packs/impact/app/services/impact/outcomes.rb`
- Modify: `packs/impact/app/services/impact/rules.rb`
- Test: `packs/impact/test/impact/assessment_test.rb`

**Interfaces:**
- Consumes: Tasks 3 and 4
- Produces:
  - `Impact::Outcomes::ALL = %i[incomplete specified needs_site_check engineering_review]`
  - `Impact::Outcomes::ORDER = %i[specified needs_site_check engineering_review]`
  - `Impact::Assessment` (`Data`): `energy`, `verdicts` ([`Verdict`], empty when the
    energy is unknown), `outcome`, `reason`, `recommendation` (`Impact::Barrier` or
    nil), `other_fitting` ([`Barrier`]), `unmeasured`.
    `reason` is one of:
    - `:missing_facts`
    - `:clearance_not_given`
    - `:no_barrier_rated_high_enough`
    - `:covering_barriers_do_not_fit` (any verdict is `does_not_fit`)
    - `nil` when `specified`
  - `Impact::Rules.assess(point, barriers) -> Impact::Assessment`: considers only the
    barriers of the point's application, and follows impact.md section 6. Fitting
    barriers are sorted by rating joules, then deflection, then name; the first is the
    recommendation.

- [ ] **Step 1: Write the failing tests.** The S1 barriers are PR-4, PR-12, PR-18 and
  PR-24, with the values from the design's seeded catalog table.
  ```ruby
  test "IH-15: unknown energy is incomplete, with no verdict and no barrier" do
    a = assess(point(max_load_kg: Impact::Fact.unknown), s1_barriers)
    assert_equal [ :incomplete, :missing_facts, nil, [] ], [ a.outcome, a.reason, a.recommendation, a.verdicts ]
  end

  test "IH-19: the fitting barrier with the lowest rating is recommended, the others listed" do
    a = assess(point, s1_barriers)
    assert_equal [ :specified, "PR-12", [ "PR-24" ] ], [ a.outcome, a.recommendation.name, a.other_fitting.map(&:name) ]
  end

  test "IH-19: ties go to the smaller deflection, then the name" do
    a = assess(point, [ barrier("B", 20_000, 12_000, 400), barrier("A", 20_000, 12_000, 400), barrier("C", 20_000, 12_000, 300) ])
    assert_equal [ "C", "A", "B" ], [ a.recommendation.name, *a.other_fitting.map(&:name) ]
  end

  test "IH-24: unknown clearance with a covering barrier needs a site check" do
    a = assess(point(clearance_mm: Impact::Fact.unknown), s1_barriers)
    assert_equal [ :needs_site_check, :clearance_not_given, nil ], [ a.outcome, a.reason, a.recommendation ]
  end

  test "IH-18: S3, no barrier rated high enough, goes to engineering review" do
    s3 = point(application: :column, vehicle_mass_kg: fact("12000"), max_load_kg: fact("3000"), speed_kmh: fact("12"))
    a = assess(s3, [ column("CG-9", 15_000, 9_000, 100), column("CG-40", 60_000, 40_000, 150) ])
    assert_equal [ :engineering_review, :no_barrier_rated_high_enough, nil ], [ a.outcome, a.reason, a.recommendation ]
  end

  test "IH-18: covering barriers that do not fit go to engineering review, and so does an empty catalog" do
    assert_equal :covering_barriers_do_not_fit, assess(point(clearance_mm: fact("100")), s1_barriers).reason
    assert_equal :no_barrier_rated_high_enough, assess(point, []).reason
  end

  test "IH-23: the outcome names every fact it rests on that was not measured" do
    a = assess(point(speed_kmh: fact("8", :declared), clearance_mm: fact("600", :estimated)), s1_barriers)
    assert_equal %i[speed_kmh], a.energy.unmeasured
    assert_equal %i[speed_kmh clearance_mm], a.unmeasured
  end
  ```
  Also assert that a column barrier rated 1,000,000 J never counts for a pedestrian point.
- [ ] **Step 2:** Run `bin/rails test packs/impact`. Expected: FAIL.
- [ ] **Step 3:** Implement `assess` and the outcome constants.
- [ ] **Step 4:** Run `bin/rails test packs/impact test/boundaries_test.rb && bin/packwerk check`.
  Expected: PASS.
- [ ] **Step 5:** Commit: "Assess a hazard point: outcome and recommendation".

---

### Task 6: Catalog pack, seeded

**Files:**
- Create from the pack template: `packs/catalog/{package.yml,AGENTS.md,CLAUDE.md}`
  (dependencies: `packs/impact`)
- Create:
  - `db/migrate/20261121120000_create_catalog_tables.rb`
  - `packs/catalog/app/models/catalog.rb`
  - `packs/catalog/app/models/catalog/barrier.rb`
  - `packs/catalog/app/models/catalog/barrier_rating.rb`
  - `packs/catalog/app/services/catalog/seed.rb`
- Modify: `db/seeds.rb` (calls `Catalog::Seed.call`), `db/schema.rb` (regenerated)
- Test: `packs/catalog/test/catalog/catalog_test.rb`

**Interfaces:**
- Consumes: `Impact::Barrier`, `Impact::APPLICATIONS`
- Produces:
  - `Catalog::NOTICE = "example values, not manufacturer data"`
  - `Catalog.table_name_prefix` returns `"catalog_"`
  - `Catalog.barriers_for(applications) -> Hash{Symbol => Array<Impact::Barrier>}`:
    every requested application is a key (`[]` when it has none); one query, with the
    ratings preloaded.
  - `Catalog::Barrier#to_impact -> Impact::Barrier`
  - `Catalog::Seed.call`: idempotent; upserts by name and replaces the ratings.

Tables and checks: design.md, Data. Seed rows: the design's table, plus these (45° /
90° / deflection):
| Name | Application | 45° | 90° | Deflection |
|---|---|---|---|---|
| TB-30 | traffic | 50,000 J | 30,000 J | 600 mm |
| TB-60 | traffic | 90,000 J | 60,000 J | 900 mm |
| RE-6 | rack_end | 10,000 J | 6,000 J | 200 mm |
| RE-15 | rack_end | 25,000 J | 15,000 J | 300 mm |
| MG-10 | machine | 16,000 J | 10,000 J | 250 mm |
| MG-30 | machine | 45,000 J | 30,000 J | 400 mm |

- [ ] **Step 1: Write the failing tests**
  ```ruby
  test "the seed is idempotent" do
    2.times { Catalog::Seed.call }
    assert_equal [ 12, 24 ], [ Catalog::Barrier.count, Catalog::BarrierRating.count ]
  end

  test "every seeded barrier is tested at 45 and 90 degrees, never higher at 90" do
    Catalog::Seed.call
    Catalog.barriers_for(Impact::APPLICATIONS).values.flatten.each do |b|
      assert_equal [ BigDecimal("45"), BigDecimal("90") ], b.ratings.keys.sort
      assert_operator b.ratings[BigDecimal("90")], :<=, b.ratings[BigDecimal("45")]
    end
  end

  test "barriers_for returns impact barriers per application" do
    Catalog::Seed.call
    found = Catalog.barriers_for(%i[pedestrian column])
    assert_equal %w[PR-12 PR-18 PR-24 PR-4], found[:pedestrian].map(&:name).sort
    assert_equal BigDecimal("450"), found[:pedestrian].find { _1.name == "PR-12" }.deflection_mm
  end
  ```
- [ ] **Step 2:** Run `bin/rails db:migrate && bin/rails test packs/catalog`.
  Expected: FAIL.
- [ ] **Step 3:** Write the migration (with check constraints), the models and the seed.
- [ ] **Step 4:** Run `bin/rails test packs/catalog && bin/packwerk validate && bin/packwerk check`.
  Expected: PASS.
- [ ] **Step 5:** Commit: "Add the seeded, read-only barrier catalog".

---

### Task 7: Surveys pack: models and CreateSurvey

**Files:**
- Create from the pack template: `packs/surveys/{package.yml,AGENTS.md,CLAUDE.md}`
  (dependencies: `packs/impact`, `packs/catalog`)
- Create:
  - `db/migrate/20261121120100_create_survey_tables.rb`
  - `packs/surveys/app/models/surveys/survey.rb`
  - `packs/surveys/app/models/surveys/hazard_point.rb`
  - `packs/surveys/app/services/surveys/result.rb`
  - `packs/surveys/app/services/surveys/create_survey.rb`
- Test: `packs/surveys/test/surveys/create_survey_test.rb`
- Test support: `packs/surveys/test/support/survey_attributes.rb`, module
  `SurveyAttributes`. Tasks 8, 10 and 11 require it too.

**Interfaces:**
- Consumes: `Impact::FACTS`, `Impact::SOURCES`, `Impact::APPLICATIONS`,
  `Impact.out_of_range`, `Impact::HazardPoint`
- Produces:
  - `Surveys::Survey` (table `surveys`), with `has_many :hazard_points` ordered by
    `position`.
  - `Surveys::HazardPoint` (table `hazard_points`), with `#to_impact -> Impact::HazardPoint`.
  - `Surveys::Result` (`Data`: `value`, `errors` Hash{String => String}, one message
    per field), with `.success(value)`, `.failure(errors)` and `#success?`.
  - `Surveys::CreateSurvey.call(attributes) -> Surveys::Result`. `attributes` is a
    Hash with string keys: `site_name`, `customer_name`, `surveyed_on`, `mode`,
    `notes`, `hazard_points` (an Array of Hashes: `name`, `zone`, `application`, and
    for each fact `f`, `f` and `"#{f}_source"`). Positions are 1..n in order. It
    saves everything in one transaction, or nothing.

Error keys and messages (exact):
| Key | When | Message |
|---|---|---|
| `site_name`, `customer_name` | blank after stripping | "Enter the site name." / "Enter the customer name." |
| `surveyed_on` | blank / not a date | "Enter the survey date." / "Enter a date, like 2026-11-21." |
| `mode` | blank or outside the list | "Choose on site or remote." |
| `hazard_points` | none | "Add at least one hazard point." |
| `hazard_points.N.name` / `.zone` | blank | "Enter a name for this point." / "Enter the zone." |
| `hazard_points.N.application` | blank or outside the list | "Choose an application." |
| `hazard_points.N.<fact>` | raw text not matching `/\A-?\d+(\.\d+)?\z/` after stripping | "Enter a number, like 8 or 8.5." |
| `hazard_points.N.<fact>` | out of range | `Impact.out_of_range` |
| `hazard_points.N.<fact>` | a source with no value | "Enter a value, or clear its source." |
| `hazard_points.N.<fact>_source` | a value with no source | "Choose where this value came from." |
| `hazard_points.N.<fact>_source` | outside the list | "Choose measured, estimated or declared." |

`N` counts from 0, in the form's order. Validate the number format on
`<fact>_before_type_cast`: Rails casts "abc" to 0 and "4,000" to 4.

- [ ] **Step 1: Write the failing tests.** `SurveyAttributes` provides:
  - `s1`: valid attributes with string keys. Northgate DC, Acme Logistics, 2026-11-21,
    `on_site`, and one point "Aisle 4 walkway", zone "Aisle 4", pedestrian, 4000
    measured, 600 estimated, 8 declared, 90 estimated, 600 measured.
  - `with_point(attrs, changes)`: returns `attrs` with `changes` merged into its first
    point.
  - `create_survey(attrs)`: `Surveys::CreateSurvey.call(attrs).value`.
  ```ruby
  test "IH-20: a valid survey is saved with its points in the order given" do
    attrs = s1.merge("hazard_points" => [ s1["hazard_points"][0], s1["hazard_points"][0].merge("name" => "Dock 2") ])
    result = Surveys::CreateSurvey.call(attrs)
    assert result.success?
    assert_equal [ [ 1, "Aisle 4 walkway" ], [ 2, "Dock 2" ] ], result.value.hazard_points.map { [ _1.position, _1.name ] }
  end

  test "IH-21: invalid fields save nothing and say what is wrong next to each field" do
    result = Surveys::CreateSurvey.call(s1.merge("site_name" => "   ", "mode" => "flying").then { with_point(_1, "impact_angle_deg" => "0", "speed_kmh_source" => "") })
    assert_equal "Enter the site name.", result.errors["site_name"]
    assert_equal "Choose on site or remote.", result.errors["mode"]
    assert_equal "The angle must be between 1 and 90 degrees.", result.errors["hazard_points.0.impact_angle_deg"]
    assert_equal "Choose where this value came from.", result.errors["hazard_points.0.speed_kmh_source"]
    assert_equal 0, Surveys::Survey.count
  end

  test "IH-21: unreadable numbers and dates are errors, never 0" do
    [ "abc", "4,000", "8,5" ].each do |raw|
      result = Surveys::CreateSurvey.call(with_point(s1, "speed_kmh" => raw))
      assert_equal "Enter a number, like 8 or 8.5.", result.errors["hazard_points.0.speed_kmh"], raw
    end
    assert_equal "Enter a date, like 2026-11-21.", Surveys::CreateSurvey.call(s1.merge("surveyed_on" => "2026-13-45")).errors["surveyed_on"]
  end

  test "IH-21: a source with no value, and a survey with no point, are rejected" do
    assert_equal "Enter a value, or clear its source.",
      Surveys::CreateSurvey.call(with_point(s1, "max_load_kg" => "", "max_load_kg_source" => "estimated")).errors["hazard_points.0.max_load_kg"]
    assert_equal "Add at least one hazard point.", Surveys::CreateSurvey.call(s1.merge("hazard_points" => [])).errors["hazard_points"]
  end

  test "IH-23: each fact keeps its source, and an unknown stays nil" do
    point = Surveys::CreateSurvey.call(with_point(s1, "clearance_mm" => "", "clearance_mm_source" => "")).value.hazard_points.first
    assert_equal [ "estimated", nil, nil ], [ point.max_load_kg_source, point.clearance_mm, point.clearance_mm_source ]
  end
  ```
- [ ] **Step 2:** Run `bin/rails db:migrate && bin/rails test packs/surveys`.
  Expected: FAIL.
- [ ] **Step 3:** Write the migration (with check constraints), the models with
  validations, `Result` and `CreateSurvey`. Use `normalizes` to strip text and turn a
  blank source into `nil`.
- [ ] **Step 4:** Run `bin/rails test packs/surveys && bin/packwerk check`. Expected: PASS.
- [ ] **Step 5:** Commit: "Create a survey with its hazard points, validated as a whole".

---

### Task 8: AssessSurvey and ListSurveys

**Files:**
- Create:
  - `packs/surveys/app/services/surveys/assess_survey.rb`
  - `packs/surveys/app/services/surveys/list_surveys.rb`
  - `packs/surveys/app/services/surveys/survey_assessment.rb`
  - `packs/surveys/app/services/surveys/survey_list.rb`
- Test: `packs/surveys/test/surveys/assess_survey_test.rb`, `packs/surveys/test/surveys/list_surveys_test.rb`

**Interfaces:**
- Consumes: `Catalog.barriers_for`, `Impact::Rules.assess`, `Surveys::CreateSurvey`
- Produces:
  - `Surveys::SurveyAssessment` (`Data`: `survey`, `points`), where `points` is an
    Array of `Surveys::PointAssessment` (`Data`: `record` a `Surveys::HazardPoint`,
    `assessment` an `Impact::Assessment`).
  - `Surveys::AssessSurvey.call(survey_id) -> Surveys::SurveyAssessment`. It raises
    `ActiveRecord::RecordNotFound` for an unknown id.
  - `Surveys::SurveyList` (`Data`: `surveys`, an Array of `Surveys::SurveySummary`).
  - `Surveys::SurveySummary` (`Data`: `id`, `site_name`, `customer_name`,
    `surveyed_on` Date, `mode` String, `point_count` Integer).
  - `Surveys::ListSurveys.call -> Surveys::SurveyList`: latest `surveyed_on` first,
    then latest `created_at`.

- [ ] **Step 1: Write the failing tests.** Setup: `Catalog::Seed.call`, and include
  `SurveyAttributes`.
  ```ruby
  test "IH-25: an open survey follows the current catalog" do
    id = Surveys::CreateSurvey.call(s1).value.id
    assert_equal "PR-12", Surveys::AssessSurvey.call(id).points.first.assessment.recommendation.name
    Catalog::Barrier.find_by!(name: "PR-12").update!(deflection_mm: 650)
    assert_equal "PR-24", Surveys::AssessSurvey.call(id).points.first.assessment.recommendation.name
  end

  test "an unknown survey id raises RecordNotFound" do
    assert_raises(ActiveRecord::RecordNotFound) { Surveys::AssessSurvey.call(0) }
  end

  test "surveys are listed latest date first, with their point counts" do
    Surveys::CreateSurvey.call(s1.merge("site_name" => "Older", "surveyed_on" => "2026-10-01"))
    Surveys::CreateSurvey.call(s1)
    list = Surveys::ListSurveys.call.surveys
    assert_equal [ [ "Northgate DC", 1 ], [ "Older", 1 ] ], list.map { [ _1.site_name, _1.point_count ] }
  end
  ```
- [ ] **Step 2:** Run `bin/rails test packs/surveys`. Expected: FAIL.
- [ ] **Step 3:** Implement. `AssessSurvey` makes one query for the survey and its
  points, and one `Catalog.barriers_for` call for the applications present.
- [ ] **Step 4:** Run `bin/rails test packs && bin/packwerk check`. Expected: PASS.
- [ ] **Step 5:** Commit: "Assess and list surveys from the current catalog".

---

### Task 9: Alba, Typelizer, formatting and the generated-types check (ADR 0006)

**Files:**
- Modify: `Gemfile`, `Gemfile.lock`, `config/ci.rb`, `.github/workflows/ci.yml`, `package.yml`
  (root dependencies: `packs/impact`, `packs/catalog`, `packs/surveys`)
- Create:
  - `app/resources/application_resource.rb`
  - `app/resources/survey_list_page_resource.rb`
  - `app/resources/survey_summary_resource.rb`
  - `app/formatters/quantity_format.rb`
  - `app/frontend/types/serializers/` (generated, committed)
- Test: `test/formatters/quantity_format_test.rb`

**Interfaces:**
- Consumes: `Surveys::SurveyList`, `Surveys::SurveySummary`
- Produces:
  - `ApplicationResource`: `include Alba::Resource`; `helper Typelizer::DSL`.
  - `QuantityFormat.amount(value, unit) -> String`: Integer or BigDecimal in;
    thousands separator ","; no trailing zeros; a space before the unit except "°".
  - `QuantityFormat.date(date) -> String`, like "21 Nov 2026".
  - `SurveyListPageResource` (object: `Surveys::SurveyList`) → generated TS type
    `SurveyListPage`, with `surveys` from `SurveySummaryResource`. `surveyed_on` is
    formatted with `QuantityFormat.date`; `mode` is `"on_site" | "remote"`.

- [ ] **Step 1: Write the failing test**
  ```ruby
  test "quantities and dates are formatted once, on the server" do
    assert_equal "4,000 kg", QuantityFormat.amount(BigDecimal("4000"), "kg")
    assert_equal "8.05 km/h", QuantityFormat.amount(BigDecimal("8.05"), "km/h")
    assert_equal "90°", QuantityFormat.amount(BigDecimal("90.0"), "°")
    assert_equal "11,359 J", QuantityFormat.amount(11_359, "J")
    assert_equal "1,234,567.5 kg", QuantityFormat.amount(BigDecimal("1234567.50"), "kg")
    assert_equal "21 Nov 2026", QuantityFormat.date(Date.new(2026, 11, 21))
  end
  ```
- [ ] **Step 2:** Run `bin/rails test test/formatters`. Expected: FAIL.
- [ ] **Step 3:** Add `gem "alba", "~> 4.0"` and `gem "typelizer", "~> 0.15"` to the
  default group, then `bundle install`. Implement `QuantityFormat` and the resources;
  give every attribute a `typelize`.
- [ ] **Step 4: Check what Typelizer generates for a resource over a plain object
  (the design's first risk)**

  Run: `TYPELIZER=true bin/rails typelizer:types:refresh && cat app/frontend/types/serializers/*.ts`

  Expected: `SurveyListPage` with `surveys: Array<SurveySummary>`, and every field
  typed as in design.md, Interfaces. `grep -rn "unknown" app/frontend/types/serializers`
  prints nothing.

  If Typelizer can't type a plain-object resource, stop and report; don't work around it.
- [ ] **Step 5: Add the CI check** to `config/ci.rb`, before "Types: TypeScript":
  ```ruby
  step "Types: generated page types are current",
    "TYPELIZER=true bin/rails typelizer:types:refresh && " \
    "test -z \"$(git status --porcelain -- app/frontend/types/serializers)\" && " \
    "! grep -rn unknown app/frontend/types/serializers"
  ```
  Add the same command to the `test` job of `.github/workflows/ci.yml`, after `npm ci`
  and before the tests, with `RAILS_ENV: test`, `DATABASE_URL` as in that job, and
  `TYPELIZER: "true"`.
- [ ] **Step 6:** Run `bin/rails test test/formatters && bin/packwerk check && npm run check`.
  Expected: PASS.
- [ ] **Step 7:** Commit, including the generated files: "Generate page types from Alba
  resources with Typelizer".

---

### Task 10: Survey list and survey page

**Files:**
- Create:
  - `app/controllers/surveys_controller.rb`
  - `app/resources/survey_page_resource.rb`, plus nested resources as needed
  - `app/frontend/pages/surveys/index.tsx`, `app/frontend/pages/surveys/show.tsx`
- Modify: `config/routes.rb`: `root "surveys#index"` and
  `resources :surveys, only: %i[index show]`
- Test: `test/controllers/surveys_controller_test.rb`

**Interfaces:**
- Consumes: `Surveys::ListSurveys`, `Surveys::AssessSurvey`, `Catalog::NOTICE`,
  `Impact::FACTS`, `QuantityFormat`, `SurveyListPageResource`
- Produces:
  - `SurveysController#index` renders `surveys/index` with
    `SurveyListPageResource.new(Surveys::ListSurveys.call).serializable_hash`.
  - `#show` renders `surveys/show` with
    `SurveyPageResource.new(Surveys::AssessSurvey.call(params[:id])).serializable_hash`.
  - Generated TS type `SurveyPage`, shaped exactly as design.md, Interfaces.

Text the resource writes:
- **Missing facts:** "maximum load not given"; "vehicle mass and maximum load not
  given"; three or more as "a, b and c not given".
- **Unmeasured:** "maximum load (estimated)".
- **Rating:** "12,000 J at 90°", or `null` when not rated.
- **Verdict reasons:**
  - `not_rated`: "not tested at 60° or steeper" or "its tested energy rises with the angle"
  - `too_weak`: "4,000 J is below 11,359 J"
  - `check_space`: "clearance not given"
  - `does_not_fit`: "deflects 700 mm, 600 mm free"
  - `fits`: `null`
- **Outcome labels:** "Incomplete", "Specified", "Needs a site check", "Engineering review".
- **Outcome reasons:**
  - `missing_facts`: as above
  - `clearance_not_given`: "clearance not given"
  - `no_barrier_rated_high_enough`: "no barrier rated high enough"
  - `covering_barriers_do_not_fit`: "the barriers that cover it do not fit the space"
- **Application labels:** "Pedestrian", "Traffic", "Rack end", "Column", "Machine".

- [ ] **Step 1: Write the failing tests.** Copy the `inertia_page` helper from the
  deleted home test. Require and include `SurveyAttributes` (Task 7). Setup:
  `Catalog::Seed.call` and `@s1 = create_survey(s1)`.
  ```ruby
  test "IH-14: the survey page shows the required energy as text" do
    get survey_path(@s1)
    assert_equal "11,359 J", point(0).dig("energy", "value")
  end

  test "IH-17: a barrier that does not fit shows why" do
    get survey_path(@s1)
    pr18 = point(0)["barriers"].find { _1["name"] == "PR-18" }
    assert_equal [ "does_not_fit", "deflects 700 mm, 600 mm free" ], pr18.values_at("verdict", "reason")
  end

  test "IH-15: an unknown fact shows unknown, names it, and lists no barrier" do
    get survey_path(create_survey(with_point(s1, "max_load_kg" => "", "max_load_kg_source" => "")))
    assert_equal [ nil, "maximum load not given" ], point(0)["energy"].values_at("value", "reason")
    assert_equal [ "incomplete", [] ], [ point(0).dig("outcome", "status"), point(0)["barriers"] ]
  end

  test "IH-22: the survey page says the catalog is example values" do
    get survey_path(@s1)
    assert_equal "example values, not manufacturer data", inertia_page.dig("props", "catalog_notice")
  end

  test "IH-23: the page names the facts each result rests on that were not measured" do
    get survey_path(@s1)
    assert_equal [ "maximum load (estimated)", "speed (declared)", "impact angle (estimated)" ], point(0).dig("energy", "unmeasured")
  end

  test "IH-20: the list shows saved surveys" do
    get root_path
    assert_equal "surveys/index", inertia_page["component"]
    assert_equal [ "Northgate DC" ], inertia_page.dig("props", "surveys").map { _1["site_name"] }
  end

  test "an unknown survey is a 404" do
    get survey_path(999_999)
    assert_response :not_found
  end
  ```
  Here `point(i)` is `inertia_page.dig("props", "points", i)`.
- [ ] **Step 2:** Run `bin/rails test test/controllers/surveys_controller_test.rb`.
  Expected: FAIL.
- [ ] **Step 3:** Implement the controller, routes and resources. Then run
  `TYPELIZER=true bin/rails typelizer:types`, and write `index.tsx` and `show.tsx`
  from the design's Prototype, typed with `SurveyListPage` and `SurveyPage` from
  `@/types/serializers`. `show.tsx` prints `catalog_notice` under the header, and
  shows the barrier table only when `barriers` is not empty.
- [ ] **Step 4:** Run `bin/rails test test/controllers && npm run check` and the CI
  types step from Task 9. Expected: PASS.
- [ ] **Step 5:** Commit: "Show the survey list and each survey's specification".

---

### Task 11: New survey form

**Files:**
- Create: `app/resources/survey_form_page_resource.rb`, `app/frontend/pages/surveys/new.tsx`
- Modify: `app/controllers/surveys_controller.rb`, `config/routes.rb`
  (`only: %i[index new create show]`)
- Test: `test/controllers/surveys_controller_test.rb`

**Interfaces:**
- Consumes: `Surveys::CreateSurvey`, `Impact::APPLICATIONS`, `Impact::SOURCES`, `Impact::FACTS`
- Produces:
  - `#new` renders `surveys/new` with `SurveyFormPageResource.new(Impact).serializable_hash`.
    The type is `SurveyFormPage`: `modes`, `applications`, `sources` and `facts`, as
    in design.md.
  - `#create` permits `survey: [:site_name, :customer_name, :surveyed_on, :mode, :notes,
    hazard_points: [:name, :zone, :application, <each fact>, <each fact>_source]]`.
    It passes `.to_h` with string keys to `CreateSurvey`. On success it redirects to
    `survey_path`; on failure,
    `redirect_to new_survey_path, inertia: { errors: result.errors }`.
  - Labels: modes "On site" / "Remote"; sources "measured", "estimated", "declared";
    fact labels with a capital first letter ("Vehicle mass").

- [ ] **Step 1: Write the failing tests**
  ```ruby
  test "IH-20: submitting a valid survey saves it and opens its page" do
    assert_difference -> { Surveys::Survey.count }, 1 do
      post surveys_path, params: { survey: s1 }, as: :json
    end
    assert_redirected_to survey_path(Surveys::Survey.last)
  end

  test "IH-21: an invalid survey comes back to the form with an error per field" do
    post surveys_path, params: { survey: with_point(s1.merge("site_name" => ""), "speed_kmh" => "0") }, as: :json
    assert_redirected_to new_survey_path
    follow_redirect!
    errors = inertia_page.dig("props", "errors")
    assert_equal "Enter the site name.", errors["site_name"]
    assert_equal "Speed must be above 0 km/h.", errors["hazard_points.0.speed_kmh"]
  end

  test "the form receives its choice lists from the server" do
    get new_survey_path
    assert_equal %w[pedestrian traffic rack_end column machine], inertia_page.dig("props", "applications").map { _1["value"] }
  end
  ```
- [ ] **Step 2:** Run `bin/rails test test/controllers/surveys_controller_test.rb`.
  Expected: FAIL.
- [ ] **Step 3:** Implement the actions and the resource, regenerate the types, and
  write `new.tsx` from the design's form sketch with Inertia's `useForm`.
  - Each fact is `<input type="text" inputMode="decimal">`, so the server sees exactly
    what was typed. A number input would blank invalid text and turn it into unknown.
  - Each source is a `<select>` whose first option is empty; nothing is pre-selected.
  - The form starts with one empty point and has Add and Remove buttons.
  - Errors are read with `form.errors["hazard_points.0.speed_kmh"]`. The
    `hazard_points` error shows above the points.
- [ ] **Step 4:** Run `bin/rails test test packs && npm run check` and the types step.
  Expected: PASS.
- [ ] **Step 5:** Commit: "Add the new survey form".

---

### Task 12: Whole-change verification

**Files:**
- Modify: `docs/changes/001-site-survey-specification/tasks.md` (tick)

- [ ] **Step 1:** Run `bin/ci`. Expected: every step green, including
  "Types: generated page types are current".
- [ ] **Step 2:** Run `bin/rails test test/traceability_test.rb`. Expected: PASS. Every
  id from IH-7 and IH-14 to IH-25 has a test, and no test names an unknown id.
- [ ] **Step 3: Walk the scenarios by hand.**
  - Run `bin/rails db:seed && bin/dev`.
  - Enter S1, S2 and S3 from `docs/product/scenarios.md` at http://localhost:3000.
  - Expected: S1 shows 11,359 J, recommends PR-12, also fits PR-24, and PR-18 doesn't
    fit (700 mm, 600 mm free). S2 shows unknown energy, "maximum load not given",
    Incomplete, and no barriers. S3 shows 83,334 J, Engineering review, and "no
    barrier rated high enough".
  - Note anything that differs in `tasks.md` under Review, for the reviewer.
- [ ] **Step 4:** Tick every Build line in `tasks.md` whose test was seen red, then green.
- [ ] **Step 5:** Commit: "Verify change 001 end to end".
