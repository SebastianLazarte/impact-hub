# frozen_string_literal: true

require "bigdecimal"

module ImpactHelpers
  def fact(value, source = :measured)
    Impact::Fact.new(value: value, source: source)
  end

  def point(**overrides)
    Impact::HazardPoint.new(
      **{
        application: :pedestrian,
        vehicle_mass_kg: fact("4000"), max_load_kg: fact("600"), speed_kmh: fact("8"),
        impact_angle_deg: fact("90"), clearance_mm: fact("600")
      }.merge(overrides)
    )
  end

  def barrier(name, e45, e90, deflection, application: :pedestrian)
    Impact::Barrier.new(
      name: name, application: application, deflection_mm: BigDecimal(deflection.to_s),
      ratings: { BigDecimal("45") => e45, BigDecimal("90") => e90 }
    )
  end

  def column(name, e45, e90, deflection)
    barrier(name, e45, e90, deflection, application: :column)
  end

  def s1_barriers
    [ barrier("PR-4", 7_000, 4_000, 250), barrier("PR-12", 20_000, 12_000, 450),
      barrier("PR-18", 30_000, 18_000, 700), barrier("PR-24", 40_000, 24_000, 550) ]
  end

  def assess(hazard, barriers)
    Impact::Rules.assess(hazard, barriers)
  end

  def verdict(barrier, **point_overrides)
    hazard = point(**point_overrides)
    Impact::Rules.verdict(hazard, Impact::Rules.required_energy(hazard), barrier)
  end

  def kind(barrier, **point_overrides)
    verdict(barrier, **point_overrides).kind
  end
end
