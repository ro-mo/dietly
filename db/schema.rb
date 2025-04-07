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

ActiveRecord::Schema[8.0].define(version: 2025_04_07_101541) do
  create_table "appointments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "patient_id"
    t.integer "doctor_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string "status"
    t.text "notes"
  end

  create_table "daily_menus", force: :cascade do |t|
    t.integer "diet_plan_id", null: false
    t.integer "day_of_week"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["diet_plan_id"], name: "index_daily_menus_on_diet_plan_id"
  end

  create_table "diet_plans", force: :cascade do |t|
    t.integer "patient_id", null: false
    t.integer "doctor_id", null: false
    t.string "title"
    t.date "start_date"
    t.date "end_date"
    t.boolean "active", default: true
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["doctor_id"], name: "index_diet_plans_on_doctor_id"
    t.index ["patient_id"], name: "index_diet_plans_on_patient_id"
  end

  create_table "foods", force: :cascade do |t|
    t.string "name"
    t.string "category"
    t.text "description"
    t.decimal "calories_per_100g", precision: 8, scale: 2
    t.decimal "proteins_per_100g", precision: 8, scale: 2
    t.decimal "carbohydrates_per_100g", precision: 8, scale: 2
    t.decimal "fats_per_100g", precision: 8, scale: 2
    t.decimal "fiber_per_100g", precision: 8, scale: 2
    t.string "serving_size"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_foods_on_category"
    t.index ["name"], name: "index_foods_on_name"
  end

  create_table "mealfoods", force: :cascade do |t|
    t.integer "meal_id", null: false
    t.decimal "quantity", precision: 8, scale: 2
    t.string "unit"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ingredient_name"
    t.index ["meal_id"], name: "index_mealfoods_on_meal_id"
  end

  create_table "meals", force: :cascade do |t|
    t.integer "daily_menu_id", null: false
    t.string "meal_type"
    t.string "time_suggestion"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "calories", precision: 10, scale: 2, default: "0.0"
    t.decimal "proteins", precision: 10, scale: 2, default: "0.0"
    t.decimal "carbohydrates", precision: 10, scale: 2, default: "0.0"
    t.decimal "fats", precision: 10, scale: 2, default: "0.0"
    t.decimal "fiber", precision: 10, scale: 2, default: "0.0"
    t.index ["daily_menu_id"], name: "index_meals_on_daily_menu_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.string "fiscal_code"
    t.integer "doctor_id"
    t.string "albo_id"
    t.string "verification_status"
    t.string "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.integer "password_reset_attempts", default: 0
    t.datetime "password_reset_locked_until"
    t.index ["doctor_id"], name: "index_users_on_doctor_id"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["password_reset_sent_at"], name: "index_users_on_password_reset_sent_at"
    t.index ["password_reset_token"], name: "index_users_on_password_reset_token", unique: true
  end

  add_foreign_key "daily_menus", "diet_plans"
  add_foreign_key "diet_plans", "users", column: "doctor_id"
  add_foreign_key "diet_plans", "users", column: "patient_id"
  add_foreign_key "mealfoods", "meals"
  add_foreign_key "meals", "daily_menus"
  add_foreign_key "sessions", "users"
  add_foreign_key "users", "users", column: "doctor_id"
end
