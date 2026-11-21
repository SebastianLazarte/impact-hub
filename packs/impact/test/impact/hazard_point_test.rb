# frozen_string_literal: true

require "test_helper"
require_relative "../support/impact_helpers"

module Impact
  class HazardPointTest < ActiveSupport::TestCase
    include ImpactHelpers

    test "a fact with a value needs a source, and a source needs a value" do
      assert_raises(ArgumentError) { Impact::Fact.new(value: "8", source: nil) }
      assert_raises(ArgumentError) { Impact::Fact.new(value: nil, source: :measured) }
      assert_equal BigDecimal("8.05"), Impact::Fact.new(value: "8.05", source: "estimated").value
    end

    test "a hazard point rejects an angle outside 1 to 90 and an unknown application" do
      assert_raises(ArgumentError) { point(impact_angle_deg: fact("0")) }
      assert_raises(ArgumentError) { point(application: :wall) }
    end

    test "out_of_range names the limit in plain language" do
      assert_equal "Speed must be above 0 km/h.", Impact.out_of_range(:speed_kmh, BigDecimal("0"))
      assert_nil Impact.out_of_range(:max_load_kg, BigDecimal("0"))
    end
  end
end
