# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171019212541) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active"
  end

  create_table "cis", force: :cascade do |t|
    t.bigint "account_id"
    t.boolean "active", null: false
    t.text "description"
    t.string "name"
    t.integer "maximum_unavailable_children_with_service_maintained"
    t.integer "minimum_children_to_maintain_service"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_cis_on_account_id"
  end

  create_table "cis_cis", force: :cascade do |t|
    t.bigint "parent_id"
    t.bigint "child_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["child_id"], name: "index_cis_cis_on_child_id"
    t.index ["parent_id"], name: "index_cis_cis_on_parent_id"
  end

  create_table "cis_outages", force: :cascade do |t|
    t.bigint "ci_id"
    t.bigint "outage_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ci_id"], name: "index_cis_outages_on_ci_id"
    t.index ["outage_id"], name: "index_cis_outages_on_outage_id"
  end

  create_table "contributors", force: :cascade do |t|
    t.bigint "outage_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["outage_id"], name: "index_contributors_on_outage_id"
    t.index ["user_id"], name: "index_contributors_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.boolean "handled", null: false
    t.bigint "outage_id"
    t.text "text"
    t.integer "event_type", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["outage_id"], name: "index_events_on_outage_id"
  end

  create_table "notes", force: :cascade do |t|
    t.string "notable_type"
    t.bigint "notable_id"
    t.bigint "user_id"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notable_type", "notable_id"], name: "index_notes_on_notable_type_and_notable_id"
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "event_id"
    t.bigint "watch_id"
    t.integer "notification_type", default: 0
    t.boolean "notified", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_notifications_on_event_id"
    t.index ["watch_id"], name: "index_notifications_on_watch_id"
  end

  create_table "outages", force: :cascade do |t|
    t.bigint "account_id"
    t.boolean "active", null: false
    t.boolean "causes_loss_of_service", null: false
    t.boolean "completed", null: false
    t.text "description"
    t.datetime "end_time"
    t.string "name"
    t.datetime "start_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_outages_on_account_id"
    t.index ["end_time"], name: "index_outages_on_end_time"
    t.index ["start_time"], name: "index_outages_on_start_time"
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.text "content"
    t.string "searchable_type"
    t.bigint "searchable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "account_id"
    t.index ["account_id"], name: "index_pg_search_documents_on_account_id"
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable_type_and_searchable_id"
  end

  create_table "tags", force: :cascade do |t|
    t.bigint "account_id"
    t.string "taggable_type"
    t.bigint "taggable_id"
    t.text "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_tags_on_account_id"
    t.index ["taggable_type", "taggable_id"], name: "index_tags_on_taggable_type_and_taggable_id"
  end

  create_table "users", force: :cascade do |t|
    t.bigint "account_id"
    t.string "email", null: false
    t.string "name"
    t.integer "notification_periods_before_outage"
    t.string "notification_period_interval"
    t.boolean "active", null: false
    t.boolean "notify_me_before_outage", null: false
    t.boolean "notify_me_on_outage_changes", null: false
    t.boolean "notify_me_on_note_changes", null: false
    t.boolean "notify_me_on_outage_complete", null: false
    t.boolean "notify_me_on_overdue_outage", null: false
    t.time "preference_email_time"
    t.boolean "preference_individual_email_notifications", null: false
    t.boolean "preference_notify_me_by_email", null: false
    t.boolean "privilege_account", null: false
    t.boolean "privilege_edit_cis", null: false
    t.boolean "privilege_edit_outages", null: false
    t.boolean "privilege_manage_users", null: false
    t.string "time_zone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.index ["account_id"], name: "index_users_on_account_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "watches", force: :cascade do |t|
    t.bigint "user_id"
    t.string "watched_type"
    t.bigint "watched_id"
    t.boolean "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_watches_on_user_id"
    t.index ["watched_type", "watched_id"], name: "index_watches_on_watched_type_and_watched_id"
  end

  add_foreign_key "cis", "accounts"
  add_foreign_key "cis_cis", "cis", column: "child_id"
  add_foreign_key "cis_cis", "cis", column: "parent_id"
  add_foreign_key "cis_outages", "cis"
  add_foreign_key "cis_outages", "outages"
  add_foreign_key "contributors", "outages"
  add_foreign_key "contributors", "users"
  add_foreign_key "events", "outages"
  add_foreign_key "notes", "users"
  add_foreign_key "notifications", "events"
  add_foreign_key "notifications", "watches"
  add_foreign_key "outages", "accounts"
  add_foreign_key "pg_search_documents", "accounts"
  add_foreign_key "users", "accounts"
  add_foreign_key "watches", "users"
end
