# 0001. Compute the energy in exact fractions, with an upper bound for any sine that cannot be exact

Status: Accepted (2026-11-21)
Answers: P1

## Context
P1 and IH-14: the required energy is rounded up to a whole joule, any intermediate
value that cannot be exact is also rounded up, and the energy is never below the
exact value of the formula. P4 adds that the same facts with the same rules always give
the same result.

Mass, load and speed ÷ 3.6 are exact as fractions. The sine is the only part that
can't always be exact. Between 1° and 90°, sin² is a fraction only at 30°, 45°, 60° and
90°. At any other angle, a computed sine is an approximation, and if it comes out low,
rounding up at the end can still land 1 J below the true energy.

## Decision
- Compute in Ruby `Rational`: `E = (mass + load) × (speed / (36/10))² × s2 / 2`.
- `s2` is exact for an angle of exactly 30°, 45°, 60° or 90°: `1/4`, `1/2`, `3/4`, `1`.
- At any other angle:
  - `s = BigMath.sin(angle × BigMath.PI(50) / 180, 50)`.
  - Raise it by a margin: `s_up = min(1, s + 10⁻⁴⁰)`.
  - Then `s2 = Rational(s_up)²`.
- The energy is `E.ceil`, a whole number of joules.
- `DIGITS = 50` and `MARGIN = 10⁻⁴⁰` are constants in the impact pack. Changing either
  one is a rules change.

**Why the margin is safe:**
- At 50 digits, `BigMath` (including its value of π) errs by far less than 10⁻⁴⁰.
- The sine rises from 0° to 90°.
- So `s + 10⁻⁴⁰` is never below the true sine.

**What it can cost:** with an irrational sin², the exact energy is never a whole number.
So the ceiling matches the true ceiling, except when the true energy sits within about
10⁻³⁵ J below a whole joule. Then the result is 1 J high, on the safe side.

**Tests:**
- The four worked examples of impact.md section 3, exactly.
- For every angle from 1° to 89.5° in steps of 0.5°, other than the four exact ones,
  the result is at least the same formula computed at 100 digits, and at most 1 J above it.

**Options considered:**
- `BigDecimal` throughout: speed ÷ 3.6 would need rounding too, so there would be more
  places where a rounding could go the wrong way.
- `Float`: no upper-bound guarantee, and not reproducible enough for P4.
- A fixed list of angles: rejected in the spec review of 2026-11-21 (gap 2). Shallow
  hazards would be over-protected.

## Consequences
- The worked examples come out exactly, and the precision is set in one place.
- Only the final whole number of joules leaves the pack, so pages never see a fraction.
- The property test must stay. Reviewers treat a change to `DIGITS` or `MARGIN` like
  any other rules change.
