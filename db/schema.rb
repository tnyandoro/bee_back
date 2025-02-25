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

ActiveRecord::Schema[7.1].define(version: 2025_02_24_205739) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "comments", force: :cascade do |t|
    t.string "content"
    t.bigint "user_id", null: false
    t.bigint "ticket_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ticket_id"], name: "index_comments_on_ticket_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "organization_id", null: false
    t.string "message"
    t.boolean "read", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "notifiable_type"
    t.bigint "notifiable_id"
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
    t.index ["organization_id"], name: "index_notifications_on_organization_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.string "email"
    t.string "web_address"
    t.string "subdomain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone_number"
    t.index ["subdomain"], name: "index_organizations_on_subdomain", unique: true
  end

  create_table "problems", force: :cascade do |t|
    t.text "description"
    t.bigint "ticket_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.bigint "organization_id", null: false
    t.bigint "creator_id"
    t.bigint "team_id"
    t.index ["ticket_id"], name: "index_problems_on_ticket_id"
    t.index ["user_id"], name: "index_problems_on_user_id"
  end

  create_table "sla_policies", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.integer "priority"
    t.integer "response_time"
    t.integer "resolution_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_sla_policies_on_organization_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.bigint "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_teams_on_organization_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "priority"
    t.bigint "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ticket_number", null: false
    t.string "ticket_type", null: false
    t.bigint "assignee_id"
    t.bigint "team_id", null: false
    t.bigint "requester_id"
    t.datetime "reported_at", null: false
    t.string "category", null: false
    t.string "caller_name", null: false
    t.string "caller_surname", null: false
    t.string "caller_email", null: false
    t.string "caller_phone", null: false
    t.string "customer", null: false
    t.string "source", null: false
    t.bigint "creator_id"
    t.bigint "user_id", null: false
    t.string "status"
    t.integer "impact", default: 0, null: false
    t.integer "urgency", default: 0, null: false
    t.datetime "response_due_at"
    t.datetime "resolution_due_at"
    t.integer "escalation_level", default: 0
    t.boolean "sla_breached", default: false
    t.bigint "sla_policy_id", null: false
    t.index ["organization_id"], name: "index_tickets_on_organization_id"
    t.index ["sla_policy_id"], name: "index_tickets_on_sla_policy_id"
    t.index ["ticket_number"], name: "index_tickets_on_ticket_number", unique: true
    t.index ["user_id"], name: "index_tickets_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.integer "role"
    t.bigint "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "department"
    t.string "position"
    t.bigint "team_id"
    t.string "auth_token"
    t.string "phone_number"
    t.string "username"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "comments", "tickets"
  add_foreign_key "comments", "users"
  add_foreign_key "notifications", "organizations"
  add_foreign_key "notifications", "users"
  add_foreign_key "problems", "tickets"
  add_foreign_key "problems", "users"
  add_foreign_key "sla_policies", "organizations"
  add_foreign_key "teams", "organizations"
  add_foreign_key "tickets", "organizations"
  add_foreign_key "tickets", "teams"
  add_foreign_key "tickets", "users"
  add_foreign_key "tickets", "users", column: "assignee_id"
  add_foreign_key "tickets", "users", column: "requester_id"
  add_foreign_key "users", "organizations"
  add_foreign_key "users", "teams"
end
