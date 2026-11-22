# frozen_string_literal: true

# PostgreSQL orders NaN above every number, so ">= 0" admits it. Reject NaN everywhere,
# and Infinity where a column has no upper bound (spec P2: never assume space).
class ForbidNanAndInfinityNumbers < ActiveRecord::Migration[8.1]
  COLUMNS = {
    hazard_points: { vehicle_mass_kg: false, max_load_kg: false, speed_kmh: false, impact_angle_deg: true, clearance_mm: false },
    catalog_barriers: { deflection_mm: false },
    catalog_barrier_ratings: { test_angle_deg: true }
  }.freeze

  def change
    COLUMNS.each do |table, columns|
      columns.each do |column, bounded|
        add_check_constraint table, "#{column} <> 'NaN'::numeric", name: "#{table}_#{column}_not_nan"
        next if bounded

        add_check_constraint table, "#{column} <> 'Infinity'::numeric", name: "#{table}_#{column}_not_infinity"
      end
    end
  end
end
