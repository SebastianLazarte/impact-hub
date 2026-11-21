# frozen_string_literal: true

require "test_helper"
require Rails.root.join("packs/surveys/test/support/survey_attributes")

class SurveysControllerTest < ActionDispatch::IntegrationTest
  include SurveyAttributes

  setup do
    Catalog::Seed.call
    @s1 = create_survey(s1)
  end

  def inertia_page
    script = Nokogiri::HTML(response.body).at_css("script[data-page]")
    assert script, "expected an Inertia page payload in the HTML"
    JSON.parse(script.text)
  end

  def point(index) = inertia_page.dig("props", "points", index)

  test "IH-14: the survey page shows the required energy as text" do
    get survey_path(@s1)
    assert_equal "11,359 J", point(0).dig("energy", "value")
  end

  test "IH-17: a barrier that does not fit shows why" do
    get survey_path(@s1)
    pr18 = point(0)["barriers"].find { _1["name"] == "PR-18" }
    assert_equal [ "does_not_fit", "deflects 700 mm, 600 mm free" ], pr18.values_at("verdict", "reason")
  end

  test "IH-15: an unknown fact shows unknown, names it, and lists no barrier" do
    get survey_path(create_survey(with_point(s1, "max_load_kg" => "", "max_load_kg_source" => "")))
    assert_equal [ nil, "maximum load not given" ], point(0)["energy"].values_at("value", "reason")
    assert_equal [ "incomplete", [] ], [ point(0).dig("outcome", "status"), point(0)["barriers"] ]
  end

  test "IH-22: the survey page says the catalog is example values" do
    get survey_path(@s1)
    assert_equal "example values, not manufacturer data", inertia_page.dig("props", "catalog_notice")
  end

  test "IH-23: the page names the facts each result rests on that were not measured" do
    get survey_path(@s1)
    assert_equal [ "maximum load (estimated)", "speed (declared)", "impact angle (estimated)" ], point(0).dig("energy", "unmeasured")
  end

  test "IH-23: outcome and verdicts also name an estimated clearance they rest on" do
    get survey_path(create_survey(with_point(s1, "clearance_mm_source" => "estimated")))
    assert_includes point(0).dig("outcome", "unmeasured"), "clearance (estimated)"
    pr12 = point(0)["barriers"].find { _1["name"] == "PR-12" }
    assert_includes pr12["unmeasured"], "clearance (estimated)"
  end

  test "IH-20: the list shows saved surveys" do
    get root_path
    assert_equal "surveys/index", inertia_page["component"]
    assert_equal [ "Northgate DC" ], inertia_page.dig("props", "surveys").map { _1["site_name"] }
  end

  test "an unknown survey is a 404" do
    get survey_path(999_999)
    assert_response :not_found
  end

  test "IH-20: submitting a valid survey saves it and opens its page" do
    assert_difference -> { Surveys::Survey.count }, 1 do
      post surveys_path, params: { survey: s1 }, as: :json
    end
    assert_redirected_to survey_path(Surveys::Survey.last)
  end

  test "IH-21: an invalid survey comes back to the form with an error per field" do
    post surveys_path, params: { survey: with_point(s1.merge("site_name" => ""), "speed_kmh" => "0") }, as: :json
    assert_redirected_to new_survey_path
    follow_redirect!
    errors = inertia_page.dig("props", "errors")
    assert_equal "Enter the site name.", errors["site_name"]
    assert_equal "Speed must be above 0 km/h.", errors["hazard_points.0.speed_kmh"]
  end

  test "the form receives its choice lists from the server" do
    get new_survey_path
    assert_equal %w[pedestrian traffic rack_end column machine], inertia_page.dig("props", "applications").map { _1["value"] }
  end
end
