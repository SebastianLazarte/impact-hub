# frozen_string_literal: true

require "bigdecimal"

# Rules for hazard points: the facts, their ranges and the vocabulary shared by the pack.
module Impact
  APPLICATIONS = %i[pedestrian traffic rack_end column machine].freeze
  SOURCES = %i[measured estimated declared].freeze

  FACTS = {
    vehicle_mass_kg: { label: "vehicle mass", unit: "kg" }.freeze,
    max_load_kg: { label: "maximum load", unit: "kg" }.freeze,
    speed_kmh: { label: "speed", unit: "km/h" }.freeze,
    impact_angle_deg: { label: "impact angle", unit: "°" }.freeze,
    clearance_mm: { label: "clearance", unit: "mm" }.freeze
  }.freeze

  ENERGY_FACTS = %i[vehicle_mass_kg max_load_kg speed_kmh impact_angle_deg].freeze

  # The message for a known value outside its range, else nil.
  def self.out_of_range(fact, value)
    case fact
    when :vehicle_mass_kg then "Vehicle mass must be above 0 kg." unless value.positive?
    when :max_load_kg then "Maximum load cannot be below 0 kg." if value.negative?
    when :speed_kmh then "Speed must be above 0 km/h." unless value.positive?
    when :impact_angle_deg then "The angle must be between 1 and 90 degrees." unless (1..90).cover?(value)
    when :clearance_mm then "Clearance cannot be below 0 mm." if value.negative?
    end
  end
end
