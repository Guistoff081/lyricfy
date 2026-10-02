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

ActiveRecord::Schema[8.1].define(version: 2026_09_15_000300) do
  create_table "exports", force: :cascade do |t|
    t.string "aspect", default: "original", null: false
    t.datetime "created_at", null: false
    t.float "end_seconds", null: false
    t.text "error_message"
    t.integer "project_id", null: false
    t.float "start_seconds", default: 0.0, null: false
    t.string "status", default: "queued", null: false
    t.string "subtitle_font", default: "Liberation Serif", null: false
    t.string "subtitle_position", default: "center", null: false
    t.integer "subtitle_size", default: 24, null: false
    t.text "subtitle_text", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_exports_on_project_id"
  end

  create_table "media_imports", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error_message"
    t.integer "project_id"
    t.string "status", default: "queued", null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.text "warning"
    t.index ["project_id"], name: "index_media_imports_on_project_id"
    t.index ["status"], name: "index_media_imports_on_status"
  end

  create_table "projects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.float "duration", null: false
    t.string "media_kind", null: false
    t.string "original_filename", null: false
    t.string "subtitle_font", default: "Liberation Serif", null: false
    t.string "subtitle_position", default: "center", null: false
    t.integer "subtitle_size", default: 24, null: false
    t.text "subtitle_text", default: "", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "exports", "projects"
  add_foreign_key "media_imports", "projects"
end
