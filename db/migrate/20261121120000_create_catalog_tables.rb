# frozen_string_literal: true

# Numbers are numeric with no precision or scale, so a value is stored as typed (P3).
# The model validations give the messages; the check constraints are a backstop.
class CreateCatalogTables < ActiveRecord::Migration[8.1]
  APPLICATIONS = %w[pedestrian traffic rack_end column machine].freeze

  def change
    create_table :catalog_barriers do |t|
      t.string :name, null: false
      t.string :application, null: false
      t.decimal :deflection_mm, null: false
      t.timestamps
      t.index :name, unique: true
      t.check_constraint "application IN (#{APPLICATIONS.map { |a| "'#{a}'" }.join(', ')})", name: "catalog_barriers_application_known"
      t.check_constraint "deflection_mm >= 0", name: "catalog_barriers_deflection_not_negative"
    end

    create_table :catalog_barrier_ratings do |t|
      t.references :barrier, null: false, foreign_key: { to_table: :catalog_barriers }, index: false
      t.decimal :test_angle_deg, null: false
      t.integer :energy_j, null: false
      t.index %i[barrier_id test_angle_deg], unique: true
      t.check_constraint "test_angle_deg >= 1 AND test_angle_deg <= 90", name: "catalog_barrier_ratings_angle_range"
      t.check_constraint "energy_j > 0", name: "catalog_barrier_ratings_energy_positive"
    end
  end
end
