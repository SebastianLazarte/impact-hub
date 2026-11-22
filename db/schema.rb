# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_11_22_100000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "catalog_barrier_ratings", force: :cascade do |t|
    t.bigint "barrier_id", null: false
    t.decimal "test_angle_deg", null: false
    t.integer "energy_j", null: false
    t.index ["barrier_id", "test_angle_deg"], name: "index_catalog_barrier_ratings_on_barrier_id_and_test_angle_deg", unique: true
    t.check_constraint "energy_j > 0", name: "catalog_barrier_ratings_energy_positive"
    t.check_constraint "test_angle_deg <> 'NaN'::numeric", name: "catalog_barrier_ratings_test_angle_deg_not_nan"
    t.check_constraint "test_angle_deg >= 1::numeric AND test_angle_deg <= 90::numeric", name: "catalog_barrier_ratings_angle_range"
  end

  create_table "catalog_barriers", force: :cascade do |t|
    t.string "name", null: false
    t.string "application", null: false
    t.decimal "deflection_mm", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_catalog_barriers_on_name", unique: true
    t.check_constraint "application::text = ANY (ARRAY['pedestrian'::character varying, 'traffic'::character varying, 'rack_end'::character varying, 'column'::character varying, 'machine'::character varying]::text[])", name: "catalog_barriers_application_known"
    t.check_constraint "deflection_mm <> 'Infinity'::numeric", name: "catalog_barriers_deflection_mm_not_infinity"
    t.check_constraint "deflection_mm <> 'NaN'::numeric", name: "catalog_barriers_deflection_mm_not_nan"
    t.check_constraint "deflection_mm >= 0::numeric", name: "catalog_barriers_deflection_not_negative"
  end

  create_table "hazard_points", force: :cascade do |t|
    t.bigint "survey_id", null: false
    t.integer "position", null: false
    t.string "name", null: false
    t.string "zone", null: false
    t.string "application", null: false
    t.decimal "vehicle_mass_kg"
    t.string "vehicle_mass_kg_source"
    t.decimal "max_load_kg"
    t.string "max_load_kg_source"
    t.decimal "speed_kmh"
    t.string "speed_kmh_source"
    t.decimal "impact_angle_deg"
    t.string "impact_angle_deg_source"
    t.decimal "clearance_mm"
    t.string "clearance_mm_source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["survey_id", "position"], name: "index_hazard_points_on_survey_id_and_position", unique: true
    t.check_constraint "(clearance_mm IS NULL) = (clearance_mm_source IS NULL)", name: "hazard_points_clearance_mm_with_source"
    t.check_constraint "(impact_angle_deg IS NULL) = (impact_angle_deg_source IS NULL)", name: "hazard_points_impact_angle_deg_with_source"
    t.check_constraint "(max_load_kg IS NULL) = (max_load_kg_source IS NULL)", name: "hazard_points_max_load_kg_with_source"
    t.check_constraint "(speed_kmh IS NULL) = (speed_kmh_source IS NULL)", name: "hazard_points_speed_kmh_with_source"
    t.check_constraint "(vehicle_mass_kg IS NULL) = (vehicle_mass_kg_source IS NULL)", name: "hazard_points_vehicle_mass_kg_with_source"
    t.check_constraint "application::text = ANY (ARRAY['pedestrian'::character varying, 'traffic'::character varying, 'rack_end'::character varying, 'column'::character varying, 'machine'::character varying]::text[])", name: "hazard_points_application_known"
    t.check_constraint "clearance_mm <> 'Infinity'::numeric", name: "hazard_points_clearance_mm_not_infinity"
    t.check_constraint "clearance_mm <> 'NaN'::numeric", name: "hazard_points_clearance_mm_not_nan"
    t.check_constraint "clearance_mm IS NULL OR clearance_mm >= 0::numeric", name: "hazard_points_clearance_mm_range"
    t.check_constraint "clearance_mm_source IS NULL OR (clearance_mm_source::text = ANY (ARRAY['measured'::character varying, 'estimated'::character varying, 'declared'::character varying]::text[]))", name: "hazard_points_clearance_mm_source_known"
    t.check_constraint "impact_angle_deg <> 'NaN'::numeric", name: "hazard_points_impact_angle_deg_not_nan"
    t.check_constraint "impact_angle_deg IS NULL OR impact_angle_deg >= 1::numeric AND impact_angle_deg <= 90::numeric", name: "hazard_points_impact_angle_deg_range"
    t.check_constraint "impact_angle_deg_source IS NULL OR (impact_angle_deg_source::text = ANY (ARRAY['measured'::character varying, 'estimated'::character varying, 'declared'::character varying]::text[]))", name: "hazard_points_impact_angle_deg_source_known"
    t.check_constraint "max_load_kg <> 'Infinity'::numeric", name: "hazard_points_max_load_kg_not_infinity"
    t.check_constraint "max_load_kg <> 'NaN'::numeric", name: "hazard_points_max_load_kg_not_nan"
    t.check_constraint "max_load_kg IS NULL OR max_load_kg >= 0::numeric", name: "hazard_points_max_load_kg_range"
    t.check_constraint "max_load_kg_source IS NULL OR (max_load_kg_source::text = ANY (ARRAY['measured'::character varying, 'estimated'::character varying, 'declared'::character varying]::text[]))", name: "hazard_points_max_load_kg_source_known"
    t.check_constraint "speed_kmh <> 'Infinity'::numeric", name: "hazard_points_speed_kmh_not_infinity"
    t.check_constraint "speed_kmh <> 'NaN'::numeric", name: "hazard_points_speed_kmh_not_nan"
    t.check_constraint "speed_kmh IS NULL OR speed_kmh > 0::numeric", name: "hazard_points_speed_kmh_range"
    t.check_constraint "speed_kmh_source IS NULL OR (speed_kmh_source::text = ANY (ARRAY['measured'::character varying, 'estimated'::character varying, 'declared'::character varying]::text[]))", name: "hazard_points_speed_kmh_source_known"
    t.check_constraint "vehicle_mass_kg <> 'Infinity'::numeric", name: "hazard_points_vehicle_mass_kg_not_infinity"
    t.check_constraint "vehicle_mass_kg <> 'NaN'::numeric", name: "hazard_points_vehicle_mass_kg_not_nan"
    t.check_constraint "vehicle_mass_kg IS NULL OR vehicle_mass_kg > 0::numeric", name: "hazard_points_vehicle_mass_kg_range"
    t.check_constraint "vehicle_mass_kg_source IS NULL OR (vehicle_mass_kg_source::text = ANY (ARRAY['measured'::character varying, 'estimated'::character varying, 'declared'::character varying]::text[]))", name: "hazard_points_vehicle_mass_kg_source_known"
  end

  create_table "surveys", force: :cascade do |t|
    t.string "site_name", null: false
    t.string "customer_name", null: false
    t.date "surveyed_on", null: false
    t.string "mode", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.check_constraint "mode::text = ANY (ARRAY['on_site'::character varying, 'remote'::character varying]::text[])", name: "surveys_mode_known"
  end

  add_foreign_key "catalog_barrier_ratings", "catalog_barriers", column: "barrier_id"
  add_foreign_key "hazard_points", "surveys", on_delete: :cascade
end
