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

ActiveRecord::Schema.define(version: 2021_02_12_120354) do

  create_table "meetings", force: :cascade do |t|
    t.string "name"
    t.datetime "start_time"
    t.text "meeting_information"
    t.integer "retention_time_days"
    t.string "admin_password"
    t.string "passcode"
    t.integer "active_voting_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["active_voting_id"], name: "index_meetings_on_active_voting_id"
    t.index ["meeting_information"], name: "index_meetings_on_meeting_information"
    t.index ["name"], name: "index_meetings_on_name"
    t.index ["retention_time_days"], name: "index_meetings_on_retention_time_days"
    t.index ["start_time"], name: "index_meetings_on_start_time"
  end

  create_table "participants", force: :cascade do |t|
    t.string "name"
    t.integer "meeting_id"
    t.string "token"
    t.boolean "permitted", default: false
    t.integer "num_votes", default: 1
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["meeting_id"], name: "index_participants_on_meeting_id"
    t.index ["name"], name: "index_participants_on_name"
    t.index ["num_votes"], name: "index_participants_on_num_votes"
    t.index ["permitted"], name: "index_participants_on_permitted"
  end

  create_table "votes", force: :cascade do |t|
    t.integer "participant_id", null: false
    t.integer "voting_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "voting_options", force: :cascade do |t|
    t.string "text"
    t.integer "voting_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["text"], name: "index_voting_options_on_text"
    t.index ["voting_id"], name: "index_voting_options_on_voting_id"
  end

  create_table "votings", force: :cascade do |t|
    t.text "text"
    t.boolean "anonymous", default: false
    t.integer "meeting_id"
    t.integer "voting_type", default: 0, null: false
    t.time "start_time"
    t.time "end_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["anonymous"], name: "index_votings_on_anonymous"
    t.index ["meeting_id"], name: "index_votings_on_meeting_id"
    t.index ["text"], name: "index_votings_on_text"
    t.index ["voting_type"], name: "index_votings_on_voting_type"
  end

end
