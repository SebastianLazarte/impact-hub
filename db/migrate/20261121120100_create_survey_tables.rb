# frozen_string_literal: true

# Numbers are numeric with no precision or scale, so a value is stored as typed (P3).
# The model validations give the messages; the check constraints are a backstop.
class CreateSurveyTables < ActiveRecord::Migration[8.1]
  APPLICATIONS = %w[pedestrian traffic rack_end column machine].freeze
  SOURCES = %w[measured estimated declared].freeze
  RANGES = {
    vehicle_mass_kg: "> 0",
    max_load_kg: ">= 0",
    speed_kmh: "> 0",
    impact_angle_deg: "BETWEEN 1 AND 90",
    clearance_mm: ">= 0"
  }.freeze

  def change
    create_table :surveys do |t|
      t.string :site_name, null: false
      t.string :customer_name, null: false
      t.date :surveyed_on, null: false
      t.string :mode, null: false
      t.text :notes
      t.timestamps
      t.check_constraint "mode IN ('on_site', 'remote')", name: "surveys_mode_known"
    end

    create_table :hazard_points do |t|
      t.references :survey, null: false, foreign_key: { on_delete: :cascade }, index: false
      t.integer :position, null: false
      t.string :name, null: false
      t.string :zone, null: false
      t.string :application, null: false
      RANGES.each_key do |fact|
        t.decimal fact
        t.string :"#{fact}_source"
      end
      t.timestamps
      t.index %i[survey_id position], unique: true
      t.check_constraint "application IN (#{APPLICATIONS.map { |a| "'#{a}'" }.join(', ')})", name: "hazard_points_application_known"
      RANGES.each do |fact, range|
        t.check_constraint "#{fact}_source IS NULL OR #{fact}_source IN (#{SOURCES.map { |s| "'#{s}'" }.join(', ')})", name: "hazard_points_#{fact}_source_known"
        t.check_constraint "(#{fact} IS NULL) = (#{fact}_source IS NULL)", name: "hazard_points_#{fact}_with_source"
        t.check_constraint "#{fact} IS NULL OR #{fact} #{range}", name: "hazard_points_#{fact}_range"
      end
    end
  end
end
