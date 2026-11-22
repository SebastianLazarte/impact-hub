# frozen_string_literal: true

module Surveys
  # One saved point (`record`) and what the rules say about it (`assessment`).
  PointAssessment = Data.define(:record, :assessment)
end
