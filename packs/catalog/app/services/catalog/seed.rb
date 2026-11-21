# frozen_string_literal: true

module Catalog
  # The only write path to the catalog. Fictional codes, no manufacturer's names (C4).
  # Each row: name, application, energy at 45 degrees (J), energy at 90 degrees (J), deflection (mm).
  module Seed
    ROWS = [
      [ "PR-4", :pedestrian, 7_000, 4_000, 250 ],
      [ "PR-12", :pedestrian, 20_000, 12_000, 450 ],
      [ "PR-18", :pedestrian, 30_000, 18_000, 700 ],
      [ "PR-24", :pedestrian, 40_000, 24_000, 550 ],
      [ "CG-9", :column, 15_000, 9_000, 100 ],
      [ "CG-40", :column, 60_000, 40_000, 150 ],
      [ "TB-30", :traffic, 50_000, 30_000, 600 ],
      [ "TB-60", :traffic, 90_000, 60_000, 900 ],
      [ "RE-6", :rack_end, 10_000, 6_000, 200 ],
      [ "RE-15", :rack_end, 25_000, 15_000, 300 ],
      [ "MG-10", :machine, 16_000, 10_000, 250 ],
      [ "MG-30", :machine, 45_000, 30_000, 400 ]
    ].freeze

    def self.call
      Catalog::Barrier.transaction do
        ROWS.each do |name, application, energy45, energy90, deflection|
          barrier = Catalog::Barrier.find_or_initialize_by(name: name)
          barrier.update!(application: application.to_s, deflection_mm: BigDecimal(deflection.to_s))
          barrier.ratings.destroy_all
          barrier.ratings.create!([
            { test_angle_deg: BigDecimal("45"), energy_j: energy45 },
            { test_angle_deg: BigDecimal("90"), energy_j: energy90 }
          ])
        end
      end
    end
  end
end
