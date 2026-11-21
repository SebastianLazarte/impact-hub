# 001. Site survey specification: tasks

<!-- Written in step 4, after the delta is merged. One task per new or changed criterion.
     Tick a task when its test was seen red, then green. -->

## Build (step 5)
- [x] IH-7: the impact pack references no Rails, database, network or LLM constant and declares no dependencies. Test: `test/boundaries_test.rb`
- [x] IH-14: required energy, rounded up. Test: `packs/impact/test/impact/energy_test.rb`, `test/controllers/surveys_controller_test.rb`
- [x] IH-15: a point missing facts is incomplete, with unknown energy and no barrier. Test: `packs/impact/test/impact/energy_test.rb`, `packs/impact/test/impact/assessment_test.rb`
- [x] IH-16: a barrier is rated at the smallest test angle not below the hazard's angle. Test: `packs/impact/test/impact/rating_test.rb`
- [x] IH-17: a barrier does not fit an unknown or too small clearance, with the reason. Test: `packs/impact/test/impact/verdict_test.rb`
- [x] IH-18: no covering barrier fits, so engineering review with the reason. Test: `packs/impact/test/impact/assessment_test.rb`
- [x] IH-19: the fitting barrier with the lowest rating is recommended, the others listed. Test: `packs/impact/test/impact/assessment_test.rb`
- [x] IH-20: a valid survey is saved with its points in order and listed. Test: `packs/surveys/test/surveys/create_survey_test.rb`, `test/controllers/surveys_controller_test.rb`
- [x] IH-21: an invalid survey saves nothing and shows a message per field. Test: `packs/surveys/test/surveys/create_survey_test.rb`, `test/controllers/surveys_controller_test.rb`
- [x] IH-22: every page with catalog values shows "example values, not manufacturer data". Test: `test/controllers/surveys_controller_test.rb`
- [x] IH-23: the sources of facts are kept, and unmeasured facts are named next to results. Test: `packs/impact/test/impact/assessment_test.rb`, `packs/surveys/test/surveys/create_survey_test.rb`
- [x] IH-24: unknown clearance with a covering barrier is marked as needing a site check. Test: `packs/impact/test/impact/assessment_test.rb`
- [x] IH-25: an open survey shows results computed from the current catalog. Test: `packs/surveys/test/surveys/assess_survey_test.rb`
- [x] Q2: one test file per use case. Test: `packs/surveys/test/surveys/`
- [x] Q3: Typelizer types are current and `tsc` passes. Test: the CI step, `npm run check`

## Review (step 6)
Walk-through over HTTP on 2026-11-22 (no browser available): S1, S2, S3 as expected; browser check pending.
- S1: 11,359 J, Specified, recommends PR-12, also fits PR-24, PR-18 does not fit ("deflects 700 mm, 600 mm free"), PR-4 too weak.
- S2: energy unknown ("maximum load not given"), Incomplete, no recommendation, no barriers listed.
- S3: 83,334 J, Engineering review ("no barrier rated high enough"), no recommendation.
- A blank site name redirects to /surveys/new; the next GET carries `errors.site_name`.
- Found and fixed: `bin/ci` failed intermittently because parallel test workers raced to build the Vite test assets after `bin/setup`; `test/test_helper.rb` now builds them once first.
- [ ] Pull request opened from the PR template, linked to this change
- [ ] Reviewed by a person against the proposal

## Release + observe (step 7)
- [ ] Released, or `N/A: <reason>`
- [ ] Success measure checked on <date>, result recorded in the proposal

## Done when
- [ ] Every ADDED or MODIFIED criterion has a passing test
- [ ] `bin/ci` is green
- [ ] `docs/specs/` and `docs/requirements.yml` contain the delta word for word
