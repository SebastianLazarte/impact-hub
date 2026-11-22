# frozen_string_literal: true

require "test_helper"
require_relative "../support/survey_attributes"

module Surveys
  class ListSurveysTest < ActiveSupport::TestCase
    include SurveyAttributes

    setup { Catalog::Seed.call }

    test "surveys are listed latest date first, with their point counts" do
      Surveys::CreateSurvey.call(s1.merge("site_name" => "Older", "surveyed_on" => "2026-10-01"))
      Surveys::CreateSurvey.call(s1)
      list = Surveys::ListSurveys.call.surveys
      assert_equal [ [ "Northgate DC", 1 ], [ "Older", 1 ] ], list.map { [ _1.site_name, _1.point_count ] }
    end
  end
end
