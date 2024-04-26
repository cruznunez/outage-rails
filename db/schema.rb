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

ActiveRecord::Schema[7.1].define(version: 2024_04_26_160205) do
  create_table "outages", force: :cascade do |t|
    t.string "eid"
    t.float "device_lat"
    t.float "device_lng"
    t.integer "customers_affected"
    t.string "cause"
    t.string "jurisdiction"
    t.json "convex_hull"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.integer "requests", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
