# frozen_string_literal: true

require "test_helper"
require_relative "../support/impact_helpers"

module Impact
  class AssessmentTest < ActiveSupport::TestCase
    include ImpactHelpers

    test "IH-15: unknown energy is incomplete, with no verdict and no barrier" do
      a = assess(point(max_load_kg: Impact::Fact.unknown), s1_barriers)
      assert_equal [ :incomplete, :missing_facts, nil, [] ], [ a.outcome, a.reason, a.recommendation, a.verdicts ]
    end

    test "IH-19: the fitting barrier with the lowest rating is recommended, the others listed" do
      a = assess(point, s1_barriers)
      assert_equal [ :specified, "PR-12", [ "PR-24" ] ], [ a.outcome, a.recommendation.name, a.other_fitting.map(&:name) ]
      assert_nil a.reason
    end

    test "IH-19: ties go to the smaller deflection, then the name" do
      a = assess(point, [ barrier("B", 20_000, 12_000, 400), barrier("A", 20_000, 12_000, 400), barrier("C", 20_000, 12_000, 300) ])
      assert_equal [ "C", "A", "B" ], [ a.recommendation.name, *a.other_fitting.map(&:name) ]
    end

    test "IH-24: unknown clearance with a covering barrier needs a site check" do
      a = assess(point(clearance_mm: Impact::Fact.unknown), s1_barriers)
      assert_equal [ :needs_site_check, :clearance_not_given, nil ], [ a.outcome, a.reason, a.recommendation ]
    end

    test "IH-18: S3, no barrier rated high enough, goes to engineering review" do
      s3 = point(application: :column, vehicle_mass_kg: fact("12000"), max_load_kg: fact("3000"), speed_kmh: fact("12"))
      a = assess(s3, [ column("CG-9", 15_000, 9_000, 100), column("CG-40", 60_000, 40_000, 150) ])
      assert_equal [ :engineering_review, :no_barrier_rated_high_enough, nil ], [ a.outcome, a.reason, a.recommendation ]
    end

    test "IH-18: covering barriers that do not fit go to engineering review, and so does an empty catalog" do
      assert_equal :covering_barriers_do_not_fit, assess(point(clearance_mm: fact("100")), s1_barriers).reason
      assert_equal :no_barrier_rated_high_enough, assess(point, []).reason
    end

    test "IH-18: a barrier of another application never counts" do
      a = assess(point, [ column("CG-HUGE", 1_000_000, 1_000_000, 100) ])
      assert_equal [ :engineering_review, [] ], [ a.outcome, a.verdicts ]
    end

    test "IH-23: the outcome names every fact it rests on that was not measured" do
      a = assess(point(speed_kmh: fact("8", :declared), clearance_mm: fact("600", :estimated)), s1_barriers)
      assert_equal %i[speed_kmh], a.energy.unmeasured
      assert_equal %i[speed_kmh clearance_mm], a.unmeasured
    end

    test "IH-23: an incomplete point still names its unmeasured facts" do
      a = assess(point(max_load_kg: Impact::Fact.unknown, speed_kmh: fact("8", :declared), clearance_mm: fact("600", :estimated)), s1_barriers)
      assert_equal %i[speed_kmh clearance_mm], a.unmeasured
    end
  end
end
