# frozen_string_literal: true

module Surveys
  # Every survey, latest survey date first, with its number of points counted in SQL.
  class ListSurveys
    def self.call = new.call

    def call
      rows = Survey
        .left_joins(:hazard_points)
        .group("surveys.id")
        .reorder(surveyed_on: :desc, created_at: :desc, id: :desc)
        .select("surveys.*", "COUNT(hazard_points.id) AS point_count")

      SurveyList.new(surveys: rows.map do |row|
        SurveySummary.new(id: row.id, site_name: row.site_name, customer_name: row.customer_name,
          surveyed_on: row.surveyed_on, mode: row.mode, point_count: row.point_count.to_i)
      end)
    end
  end
end
