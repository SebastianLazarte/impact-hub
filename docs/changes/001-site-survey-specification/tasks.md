# 001. Site survey specification: tasks

<!-- Written in step 4, after the delta is merged. One task per new or changed criterion.
     Tick a task when its test was seen red, then green. -->

## Build (step 5)
- [ ] IH-7: the impact pack references no Rails, database, network or LLM constant and declares no dependencies. Test: `test/boundaries_test.rb`
- [ ] IH-14: required energy, rounded up. Test: `packs/impact/test/impact/energy_test.rb`, `test/controllers/surveys_controller_test.rb`
- [ ] IH-15: a point missing facts is incomplete, with unknown energy and no barrier. Test: `packs/impact/test/impact/energy_test.rb`, `packs/impact/test/impact/assessment_test.rb`
- [ ] IH-16: a barrier is rated at the smallest test angle not below the hazard's angle. Test: `packs/impact/test/impact/rating_test.rb`
- [ ] IH-17: a barrier does not fit an unknown or too small clearance, with the reason. Test: `packs/impact/test/impact/verdict_test.rb`
- [ ] IH-18: no covering barrier fits, so engineering review with the reason. Test: `packs/impact/test/impact/assessment_test.rb`
- [ ] IH-19: the fitting barrier with the lowest rating is recommended, the others listed. Test: `packs/impact/test/impact/assessment_test.rb`
- [ ] IH-20: a valid survey is saved with its points in order and listed. Test: `packs/surveys/test/surveys/create_survey_test.rb`, `test/controllers/surveys_controller_test.rb`
- [ ] IH-21: an invalid survey saves nothing and shows a message per field. Test: `packs/surveys/test/surveys/create_survey_test.rb`, `test/controllers/surveys_controller_test.rb`
- [ ] IH-22: every page with catalog values shows "example values, not manufacturer data". Test: `test/controllers/surveys_controller_test.rb`
- [ ] IH-23: the sources of facts are kept, and unmeasured facts are named next to results. Test: `packs/impact/test/impact/assessment_test.rb`, `packs/surveys/test/surveys/create_survey_test.rb`
- [ ] IH-24: unknown clearance with a covering barrier is marked as needing a site check. Test: `packs/impact/test/impact/assessment_test.rb`
- [ ] IH-25: an open survey shows results computed from the current catalog. Test: `packs/surveys/test/surveys/assess_survey_test.rb`
- [ ] Q2: one test file per use case. Test: `packs/surveys/test/surveys/`
- [ ] Q3: Typelizer types are current and `tsc` passes. Test: the CI step, `npm run check`

## Review (step 6)
- [ ] Pull request opened from the PR template, linked to this change
- [ ] Reviewed by a person against the proposal

## Release + observe (step 7)
- [ ] Released, or `N/A: <reason>`
- [ ] Success measure checked on <date>, result recorded in the proposal

## Done when
- [ ] Every ADDED or MODIFIED criterion has a passing test
- [ ] `bin/ci` is green
- [ ] `docs/specs/` and `docs/requirements.yml` contain the delta word for word
