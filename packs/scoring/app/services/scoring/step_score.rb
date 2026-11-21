# frozen_string_literal: true

module Scoring
  # Everything the rules say about one step.
  StepScore = Data.define(:hours_per_month, :automation_score, :automation_method, :required_control)
end
