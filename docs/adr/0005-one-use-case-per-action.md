# 0005. Write one plain Ruby use case per action, and return a small `Result`

Status: Accepted (2026-11-21)
Answers: Q2

## Context
Q2: whatever creates or changes data applies the same validation and rules, and each
use case can be tested without HTTP. Today that is a page. Later it will be a sensor
webhook (phase 4) and an LLM tool (phase 7). The team in research R9 writes one
interactor per use case, returning a typed `Result[T]` under Sorbet.

## Decision
- **One class per action**, with `.call`, in the pack that owns the action:
  `Surveys::CreateSurvey`, `Surveys::AssessSurvey` and `Surveys::ListSurveys`.
- **What it returns:**
  - an action that writes returns a `Surveys::Result` (`Data`: `value`, `errors`,
    `success?`), where `errors` maps each field path to one message;
  - an action that only reads returns its value object.
- **Validation** lives in the models, using the impact pack's constants, and runs
  inside the use case. A controller only maps params in and the result out.
- **Tests:** each use case has a test that calls it directly.
- **No new gems:** no interactor gem and no dry-monads. Sorbet is not part of 001;
  adopting it would be its own change.

## Consequences
- The phase 4 webhook and the phase 7 tool call the same use cases as the pages.
- `Surveys::Result` lives in the surveys pack. When a second pack needs it, it moves to
  a shared pack.
- Without Sorbet, the shape of a `Result` is checked by tests, not by a type checker.
