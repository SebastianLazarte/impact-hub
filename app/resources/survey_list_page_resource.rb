# frozen_string_literal: true

class SurveyListPageResource < ApplicationResource
  many :surveys, resource: SurveySummaryResource
end
