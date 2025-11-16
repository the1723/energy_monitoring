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

ActiveRecord::Schema[8.1].define(version: 2025_11_16_153339) do
  create_table "consumptions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "date_of_reading", null: false
    t.integer "energy_type_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.integer "value", null: false
    t.index ["user_id", "energy_type_id", "date_of_reading"], name: "index_consumptions_on_user_energy_type_date", unique: true
  end

  create_table "energy_types", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "unit", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id", "name"], name: "index_energy_types_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_energy_types_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.string "name", null: false
    t.datetime "remember_created_at"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "consumptions", "energy_types"
  add_foreign_key "consumptions", "users"
  add_foreign_key "energy_types", "users"
end
