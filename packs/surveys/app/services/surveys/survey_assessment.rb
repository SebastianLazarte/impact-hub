# frozen_string_literal: true

module Surveys
  # A survey with each point's results, computed when asked for and never stored (ADR 0004).
  SurveyAssessment = Data.define(:survey, :points)
end
