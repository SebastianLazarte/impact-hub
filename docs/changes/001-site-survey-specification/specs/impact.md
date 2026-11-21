# Impact: specification

Status: **Approved** (<date of step 4>)
Pack: `packs/impact`, pure Ruby, depends on nothing (C2, IH-7)
Criteria: IH-7, IH-14 to IH-19, IH-23, IH-24

## 1. Purpose
Turn the facts of a hazard point into the energy a barrier must absorb, and match that
energy against the barriers of the [catalog](catalog.md). Only these rules compute
(P4), always on the safe side (P1, P2), and never on an invented fact (P3).

## 2. Hazard point
A **hazard point** is one place where a vehicle could hit something that must be protected.
A point records one vehicle: the one with the highest energy at that point. Several
vehicles per point is a later change.
| Fact | Type | Unknown allowed |
|---|---|---|
| `application` | `pedestrian` / `traffic` / `rack_end` / `column` / `machine` | no |
| `vehicle_mass_kg` | decimal > 0 | yes |
| `max_load_kg` | decimal >= 0 | yes |
| `speed_kmh` | decimal > 0 | yes |
| `impact_angle_deg` | decimal 1..90 (90 = head-on) | yes |
| `clearance_mm` | decimal >= 0, the free space behind the barrier line | yes |

Every fact with a value carries its source: `measured`, `estimated` (by the surveyor)
or `declared` (by the customer). A fact without a value is unknown and has no source
(P3). The application is chosen from the list and has no source.

Every result (energy, verdict, outcome) names the facts it rests on that were not
measured (IH-23). An energy rests on the mass, load, speed and angle; a verdict or an
outcome rests on those and on the clearance when it has a value. Invalid values are rejected when the point is built (IH-21).

## 3. Required energy (IH-14, IH-15)
`E = ½ × (vehicle_mass_kg + max_load_kg) × (speed_kmh ÷ 3.6 × sin(impact_angle_deg))²`,
in joules, rounded **up** to a whole joule. Any intermediate value that cannot be
exact (the sine of most angles) is also rounded up, never down, so the energy is never
below the exact value of the formula (P1). A missing mass, load, speed or angle
gives unknown, with a reason that names every missing fact (P3). No safety margin is added: the public source says the
barrier ratings already include one (research R2). Masses are in kg and speeds in km/h;
other units are a later change.

Worked examples:
| Mass + load | Speed | Angle | E |
|---|---|---|---|
| 4,000 + 600 kg | 8.05 km/h | 90° | 11,501 J |
| 4,000 + 600 kg | 8 km/h | 90° | 11,359 J |
| 4,000 + 600 kg | 8 km/h | 45° | 5,680 J |
| 12,000 + 3,000 kg | 12 km/h | 90° | 83,334 J |

The first row is the public example in research R2, which gives 11,499 J because it
rounds the speed down to 2.236 m/s first; this spec never rounds down, and rounds the
result up (11,500.44 J becomes 11,501 J).
PAS 13 is applied as explained in that public source; the standard itself has not been read.

## 4. Barrier rating at an angle (IH-16)
For a hazard point, a barrier's **rating** is its tested energy at the smallest test
angle that is not below the hazard's angle. A barrier with no such test angle is not
rated for that point, and neither is a barrier whose tested energy is higher at a
larger test angle than at a smaller one: the rule assumes ratings never rise as the angle steepens, and for such a
barrier it could overstate the rating (P1).

Example: tested at 20,000 J at 45° and 10,000 J at 90°. A 30° hazard uses 20,000 J; a
60° or 90° hazard uses 10,000 J. Because a rated barrier's tested energy never rises as
the angle steepens, the rule never overstates it.

## 5. Verdict per barrier (IH-16, IH-17)
Only barriers of the point's application are considered, and only when the required
energy is known.
| Condition (first match wins) | Verdict |
|---|---|
| no test angle at or above the hazard angle, or a tested energy that is higher at a larger test angle than at a smaller one | `not_rated` |
| rating < required energy | `too_weak` |
| clearance unknown | `check_space` |
| deflection > clearance | `does_not_fit` |
| otherwise | `fits` |

## 6. Outcome per hazard point (IH-15, IH-18, IH-19, IH-24)
| Condition (first match wins) | Outcome | Recommendation |
|---|---|---|
| required energy unknown | `incomplete` | none; reason names the missing facts |
| at least one `fits` | `specified` | the fitting barrier with the lowest rating (ties: smaller deflection, then name); the other fitting barriers are listed |
| at least one `check_space` | `needs_site_check` | none; reason: clearance not given |
| otherwise | `engineering_review` | none; reason: no barrier rated high enough, or covering barriers do not fit the space |

Outcomes are ordered `specified < needs_site_check < engineering_review`. A later rule
or an LLM may only move a point to a stricter outcome (P1). `incomplete` is outside
this order: a point leaves it only when its missing facts are given.

## 7. Open questions for review
- Is "smallest test angle not below the hazard angle" the rule an engineer would use?
  To confirm with an engineer before phase 5.
- Once prices exist (phase 5), should the recommendation prefer the lowest price among
  the fitting barriers instead of the lowest rating?
