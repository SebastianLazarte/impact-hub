# frozen_string_literal: true

require "test_helper"
require_relative "../support/survey_attributes"

module Surveys
  class AssessSurveyTest < ActiveSupport::TestCase
    include SurveyAttributes

    setup { Catalog::Seed.call }

    test "IH-25: an open survey follows the current catalog" do
      id = Surveys::CreateSurvey.call(s1).value.id
      assert_equal "PR-12", Surveys::AssessSurvey.call(id).points.first.assessment.recommendation.name
      Catalog::Barrier.find_by!(name: "PR-12").update!(deflection_mm: 650)
      assert_equal "PR-24", Surveys::AssessSurvey.call(id).points.first.assessment.recommendation.name
    end

    test "an unknown survey id raises RecordNotFound" do
      assert_raises(ActiveRecord::RecordNotFound) { Surveys::AssessSurvey.call(0) }
    end
  end
end
