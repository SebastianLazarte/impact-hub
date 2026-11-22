# frozen_string_literal: true

module Surveys
  # Runs the impact rules on every point against the catalog as it is now (IH-25, ADR 0004).
  class AssessSurvey
    def self.call(survey_id) = new(survey_id).call

    def initialize(survey_id)
      @survey_id = survey_id
    end

    def call
      survey = Survey.includes(:hazard_points).find(@survey_id)
      records = survey.hazard_points.to_a
      barriers = Catalog.barriers_for(records.map { _1.application.to_sym }.uniq)

      points = records.map do |record|
        PointAssessment.new(record: record, assessment: Impact::Rules.assess(record.to_impact, barriers.fetch(record.application.to_sym)))
      end
      SurveyAssessment.new(survey: survey, points: points)
    end
  end
end
