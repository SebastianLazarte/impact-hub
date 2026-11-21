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
end
