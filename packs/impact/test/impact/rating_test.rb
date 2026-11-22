# frozen_string_literal: true

require "test_helper"
require_relative "../support/impact_helpers"

module Impact
  class RatingTest < ActiveSupport::TestCase
    include ImpactHelpers

    test "IH-16: the rating is the tested energy at the smallest test angle not below the hazard's" do
      b = barrier("B", 20_000, 10_000, 450)
      assert_equal [ BigDecimal("45"), 20_000 ], Impact::Rules.rating(b, BigDecimal("30")).to_h.values
      assert_equal [ BigDecimal("90"), 10_000 ], Impact::Rules.rating(b, BigDecimal("60")).to_h.values
    end

    test "IH-16: no rating without a test angle at or above the hazard's, or when energy rises with the angle" do
      only45 = Impact::Barrier.new(name: "A", application: :pedestrian, deflection_mm: BigDecimal("1"), ratings: { BigDecimal("45") => 9_000 })
      assert_nil Impact::Rules.rating(only45, BigDecimal("60"))
      assert_nil Impact::Rules.rating(barrier("R", 10_000, 20_000, 450), BigDecimal("30"))
    end
  end
end
