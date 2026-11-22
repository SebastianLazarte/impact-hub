# frozen_string_literal: true

require "test_helper"
require_relative "../support/impact_helpers"

module Impact
  class VerdictTest < ActiveSupport::TestCase
    include ImpactHelpers

    test "IH-16: a barrier rated below the required energy is too weak, and equal is enough" do
      assert_equal :too_weak, kind(barrier("PR-4", 7_000, 4_000, 250))
      assert_equal :fits, kind(barrier("EQ", 20_000, 11_359, 450))
    end

    test "IH-16: an unrated barrier says why" do
      assert_equal [ :not_rated, :rises_with_angle ], verdict(barrier("R", 10_000, 20_000, 450), impact_angle_deg: fact("30")).then { [ _1.kind, _1.reason ] }
      assert_nil verdict(barrier("PR-4", 7_000, 4_000, 250)).reason
    end

    test "IH-17: unknown clearance, or a deflection above it, never fits" do
      assert_equal :does_not_fit, kind(barrier("PR-18", 30_000, 18_000, 700))
      assert_equal :fits, kind(barrier("EDGE", 30_000, 18_000, 600))
      assert_equal :check_space, kind(barrier("PR-12", 20_000, 12_000, 450), clearance_mm: Impact::Fact.unknown)
    end

    test "IH-16: too weak wins over check space when the clearance is unknown" do
      assert_equal :too_weak, kind(barrier("PR-4", 7_000, 4_000, 250), clearance_mm: Impact::Fact.unknown)
    end

    test "IH-23: a verdict names the clearance too when it was not measured" do
      v = verdict(barrier("PR-12", 20_000, 12_000, 450), clearance_mm: fact("600", :estimated))
      assert_includes v.unmeasured, :clearance_mm
    end
  end
end
