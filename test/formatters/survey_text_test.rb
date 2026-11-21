require "test_helper"

class SurveyTextTest < ActiveSupport::TestCase
  test "missing facts read as one sentence" do
    assert_nil SurveyText.missing([])
    assert_equal "maximum load not given", SurveyText.missing([ :max_load_kg ])
    assert_equal "vehicle mass and maximum load not given", SurveyText.missing(%i[vehicle_mass_kg max_load_kg])
    assert_equal "vehicle mass, maximum load and speed not given", SurveyText.missing(%i[vehicle_mass_kg max_load_kg speed_kmh])
  end
end
