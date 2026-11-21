# frozen_string_literal: true

module Surveys
  SurveySummary = Data.define(:id, :site_name, :customer_name, :surveyed_on, :mode, :point_count)
end
