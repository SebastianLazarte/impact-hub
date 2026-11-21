# frozen_string_literal: true

require "test_helper"
require_relative "../support/survey_attributes"

module Surveys
  class CreateSurveyTest < ActiveSupport::TestCase
    include SurveyAttributes

    test "IH-20: a valid survey is saved with its points in the order given" do
      attrs = s1.merge("hazard_points" => [ s1["hazard_points"][0], s1["hazard_points"][0].merge("name" => "Dock 2") ])
      result = Surveys::CreateSurvey.call(attrs)
      assert result.success?
      assert_equal [ [ 1, "Aisle 4 walkway" ], [ 2, "Dock 2" ] ], result.value.hazard_points.map { [ _1.position, _1.name ] }
    end

    test "IH-21: invalid fields save nothing and say what is wrong next to each field" do
      result = Surveys::CreateSurvey.call(s1.merge("site_name" => "   ", "mode" => "flying").then { with_point(_1, "impact_angle_deg" => "0", "speed_kmh_source" => "") })
      assert_equal "Enter the site name.", result.errors["site_name"]
      assert_equal "Choose on site or remote.", result.errors["mode"]
      assert_equal "The angle must be between 1 and 90 degrees.", result.errors["hazard_points.0.impact_angle_deg"]
      assert_equal "Choose where this value came from.", result.errors["hazard_points.0.speed_kmh_source"]
      assert_equal 0, Surveys::Survey.count
    end

    test "IH-21: unreadable numbers and dates are errors, never 0" do
      [ "abc", "4,000", "8,5" ].each do |raw|
        result = Surveys::CreateSurvey.call(with_point(s1, "speed_kmh" => raw))
        assert_equal "Enter a number, like 8 or 8.5.", result.errors["hazard_points.0.speed_kmh"], raw
      end
      [ "2026-13-45", "03/04/2026", "2026-11-21 abc", "Nov 21 2026" ].each do |raw|
        assert_equal "Enter a date, like 2026-11-21.", Surveys::CreateSurvey.call(s1.merge("surveyed_on" => raw)).errors["surveyed_on"], raw
      end
    end

    test "IH-21: a source with no value, and a survey with no point, are rejected" do
      assert_equal "Enter a value, or clear its source.",
        Surveys::CreateSurvey.call(with_point(s1, "max_load_kg" => "", "max_load_kg_source" => "estimated")).errors["hazard_points.0.max_load_kg"]
      assert_equal "Add at least one hazard point.", Surveys::CreateSurvey.call(s1.merge("hazard_points" => [])).errors["hazard_points"]
    end

    test "IH-21: an invalid second point reports only its own fields and saves nothing" do
      second = s1["hazard_points"][0].merge("name" => "", "speed_kmh" => "0")
      result = Surveys::CreateSurvey.call(s1.merge("hazard_points" => [ s1["hazard_points"][0], second ]))
      assert_equal %w[hazard_points.1.name hazard_points.1.speed_kmh], result.errors.keys.sort
      assert_equal [ 0, 0 ], [ Surveys::Survey.count, Surveys::HazardPoint.count ]
    end

    test "IH-23: each fact keeps its source, and an unknown stays nil" do
      point = Surveys::CreateSurvey.call(with_point(s1, "clearance_mm" => "", "clearance_mm_source" => "")).value.hazard_points.first
      assert_equal [ "estimated", nil, nil ], [ point.max_load_kg_source, point.clearance_mm, point.clearance_mm_source ]
    end
  end
end
