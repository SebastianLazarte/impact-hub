# frozen_string_literal: true

require "test_helper"
require_relative "../support/survey_attributes"

module Surveys
  class NumberConstraintsTest < ActiveSupport::TestCase
    include SurveyAttributes

    test "IH-21: the database refuses NaN and Infinity in every numeric column" do
      Catalog::Seed.call
      survey = create_survey(s1)
      conn = ActiveRecord::Base.connection
      %w[vehicle_mass_kg max_load_kg speed_kmh impact_angle_deg clearance_mm].each do |column|
        %w[NaN Infinity].each do |bad|
          assert_raises(ActiveRecord::StatementInvalid, "#{column} #{bad}") do
            conn.transaction(requires_new: true) do
              conn.execute("UPDATE hazard_points SET #{column} = '#{bad}' WHERE survey_id = #{survey.id}")
            end
          end
        end
      end
      assert_raises(ActiveRecord::StatementInvalid) do
        conn.transaction(requires_new: true) { conn.execute("UPDATE catalog_barriers SET deflection_mm = 'NaN'") }
      end
      assert_raises(ActiveRecord::StatementInvalid) do
        conn.transaction(requires_new: true) { conn.execute("UPDATE catalog_barrier_ratings SET test_angle_deg = 'NaN'") }
      end
    end
  end
end
