# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_08_23_134641) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "commands", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "game_id", null: false
    t.string "type"
    t.integer "piece_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "merge_mergee_id"
    t.float "transform_position_x"
    t.float "transform_position_y"
    t.float "transform_rotation"
    t.float "translate_delta_x"
    t.float "translate_delta_y"
    t.float "rotate_pivot_x"
    t.float "rotate_pivot_y"
    t.float "rotate_delta_degree"
    t.index ["game_id"], name: "index_commands_on_game_id"
    t.index ["user_id"], name: "index_commands_on_user_id"
  end

  create_table "games", force: :cascade do |t|
    t.bigint "puzzle_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "shuffled_at"
    t.float "progress", default: 0.0
    t.index ["puzzle_id"], name: "index_games_on_puzzle_id"
  end

  create_table "puzzles", force: :cascade do |t|
    t.bigint "user_id"
    t.float "linear_measure"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "difficulty", null: false
    t.integer "pieces_count"
    t.float "boundary_x"
    t.float "boundary_y"
    t.float "boundary_width"
    t.float "boundary_height"
    t.index ["user_id"], name: "index_puzzles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "password_digest"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "commands", "games"
  add_foreign_key "commands", "users"
  add_foreign_key "games", "puzzles"
end
