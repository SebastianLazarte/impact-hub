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

ActiveRecord::Schema[8.1].define(version: 2026_11_21_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "catalog_barrier_ratings", force: :cascade do |t|
    t.bigint "barrier_id", null: false
    t.decimal "test_angle_deg", null: false
    t.integer "energy_j", null: false
    t.index ["barrier_id", "test_angle_deg"], name: "index_catalog_barrier_ratings_on_barrier_id_and_test_angle_deg", unique: true
    t.check_constraint "energy_j > 0", name: "catalog_barrier_ratings_energy_positive"
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
    t.check_constraint "deflection_mm >= 0::numeric", name: "catalog_barriers_deflection_not_negative"
  end

  add_foreign_key "catalog_barrier_ratings", "catalog_barriers", column: "barrier_id"
end
