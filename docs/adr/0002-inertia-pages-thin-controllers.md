# 0002. Serve every page through Inertia from a thin controller, and submit forms with `useForm`

Status: Accepted (2026-11-21)
Answers: C1

## Context
C1: pages in React and TypeScript served by Rails, with no separate JSON API. The
baseline already renders one Inertia page from `HomeController`. Change 001 adds a
list, a form that creates a survey with all its points, and a survey page.

## Decision
- **Controllers** live in `app/controllers`, one per resource (`SurveysController`).
  Each action:
  - turns params into a call to one use case ([ADR 0005](0005-one-use-case-per-action.md));
  - renders one Inertia page, with props from one page resource
    ([ADR 0006](0006-page-data-alba-typelizer.md)).
- **Forms** use Inertia's `useForm` and post the whole survey as nested params.
- **Validation errors** come back on a redirect through Inertia's `errors`
  (`redirect_to …, inertia: { errors: }`), keyed by form field path
  (`hazard_points.0.speed_kmh`). `useForm` keeps what was typed.
- **No JSON endpoints**, and no client-side routing beyond Inertia's visits.
- **Page tests** read the Inertia payload from the HTML, as the baseline's controller
  test does, and check the props.

## Consequences
- Routing, validation and errors stay in Rails; pages only display props.
- Tests check props, not the rendered screen. That is enough while pages compute
  nothing (Q3). The step 7 walk-through checks the screen itself.
- A later JSON consumer (the phase 4 webhook) calls the same use cases from its own
  controller. It does not reuse page props.
