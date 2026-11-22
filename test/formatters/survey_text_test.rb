require "test_helper"

class SurveyTextTest < ActiveSupport::TestCase
  test "missing facts read as one sentence" do
    assert_nil SurveyText.missing([])
    assert_equal "maximum load not given", SurveyText.missing([ :max_load_kg ])
    assert_equal "vehicle mass and maximum load not given", SurveyText.missing(%i[vehicle_mass_kg max_load_kg])
    assert_equal "vehicle mass, maximum load and speed not given", SurveyText.missing(%i[vehicle_mass_kg max_load_kg speed_kmh])
  end

  Record = Struct.new(:impact_angle_deg, :clearance_mm, :vehicle_mass_kg_source, :max_load_kg_source, :speed_kmh_source,
    :impact_angle_deg_source, :clearance_mm_source)
  Point = Struct.new(:record, :assessment)

  def barrier_rows(angle, barrier)
    hazard = Impact::HazardPoint.new(
      application: :pedestrian,
      vehicle_mass_kg: Impact::Fact.new(value: "4000", source: :measured), max_load_kg: Impact::Fact.new(value: "600", source: :measured),
      speed_kmh: Impact::Fact.new(value: "8", source: :measured), impact_angle_deg: Impact::Fact.new(value: angle, source: :measured),
      clearance_mm: Impact::Fact.new(value: "600", source: :measured)
    )
    record = Record.new(BigDecimal(angle), BigDecimal("600"), "measured", "measured", "measured", "measured", "measured")
    SurveyText.barriers(Point.new(record, Impact::Rules.assess(hazard, [ barrier ])))
  end

  test "IH-16: the not-tested reason names the point's own angle" do
    low = Impact::Barrier.new(name: "LOW", application: :pedestrian, deflection_mm: 100, ratings: { BigDecimal("20") => 5_000 })
    assert_equal "not tested at 30° or steeper", barrier_rows("30", low).first.reason
    assert_equal "not tested at 60° or steeper", barrier_rows("60", low).first.reason
  end

  test "an unknown verdict reason raises instead of printing nothing" do
    verdict = Impact::Verdict.new(barrier: nil, kind: :not_rated, rating: nil, reason: :mystery, unmeasured: [])
    assert_raises(KeyError) { SurveyText.verdict_reason(verdict, nil, nil) }
  end
end
