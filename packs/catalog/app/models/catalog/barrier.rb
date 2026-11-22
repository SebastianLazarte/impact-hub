# frozen_string_literal: true

module Catalog
  class Barrier < ActiveRecord::Base
    has_many :ratings, class_name: "Catalog::BarrierRating", dependent: :destroy

    def to_impact
      Impact::Barrier.new(
        name: name,
        application: application.to_sym,
        deflection_mm: deflection_mm,
        ratings: ratings.to_h { [ _1.test_angle_deg, _1.energy_j ] }
      )
    end
  end
end
