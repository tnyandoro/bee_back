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

ActiveRecord::Schema[7.1].define(version: 2025_07_04_153515) do
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
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "business_hours", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.integer "day_of_week", null: false
    t.time "start_time", null: false
    t.time "end_time", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "day_of_week"], name: "index_business_hours_on_organization_id_and_day_of_week", unique: true
    t.index ["organization_id"], name: "index_business_hours_on_organization_id"
  end

  create_table "comments", force: :cascade do |t|
    t.string "content"
    t.bigint "user_id", null: false
    t.bigint "ticket_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ticket_id"], name: "index_comments_on_ticket_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "departments", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "name"], name: "index_departments_on_org_id_and_name", unique: true
    t.index ["organization_id"], name: "index_departments_on_organization_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "organization_id", null: false
    t.string "message"
    t.boolean "read", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "notifiable_id"
    t.string "notifiable_type"
    t.index ["notifiable_id", "notifiable_type"], name: "index_notifications_on_notifiable_id_and_type"
    t.index ["organization_id"], name: "index_notifications_on_organization_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.string "email"
    t.string "web_address"
    t.string "subdomain"
    t.string "phone_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subdomain"], name: "index_organizations_on_subdomain", unique: true
  end

  create_table "problems", force: :cascade do |t|
    t.text "description"
    t.bigint "ticket_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.bigint "organization_id", null: false
    t.integer "creator_id"
    t.integer "team_id"
    t.integer "related_incident_id"
    t.index ["ticket_id"], name: "index_problems_on_ticket_id"
    t.index ["user_id"], name: "index_problems_on_user_id"
  end

  create_table "settings", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.string "key"
    t.jsonb "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_settings_on_organization_id"
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
    t.integer "status", default: 6, null: false
    t.bigint "creator_id"
    t.datetime "response_due_at"
    t.datetime "resolution_due_at"
    t.integer "escalation_level", default: 0
    t.boolean "sla_breached", default: false
    t.bigint "sla_policy_id"
    t.integer "urgency", default: 0, null: false
    t.integer "impact", default: 0, null: false
    t.integer "calculated_priority"
    t.datetime "resolved_at"
    t.text "resolution_note"
    t.bigint "user_id"
    t.string "some_field"
    t.string "reason"
    t.string "resolution_method"
    t.string "cause_code"
    t.text "resolution_details"
    t.string "end_customer"
    t.string "support_center"
    t.string "total_kilometer"
    t.bigint "department_id"
    t.index ["assignee_id"], name: "index_tickets_on_assignee_id"
    t.index ["creator_id"], name: "index_tickets_on_creator_id"
    t.index ["department_id"], name: "index_tickets_on_department_id"
    t.index ["impact"], name: "index_tickets_on_impact"
    t.index ["organization_id"], name: "index_tickets_on_organization_id"
    t.index ["priority"], name: "index_tickets_on_priority"
    t.index ["sla_policy_id"], name: "index_tickets_on_sla_policy_id"
    t.index ["status"], name: "index_tickets_on_status"
    t.index ["team_id"], name: "index_tickets_on_team_id"
    t.index ["ticket_number"], name: "index_tickets_on_ticket_number", unique: true
    t.index ["urgency"], name: "index_tickets_on_urgency"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest"
    t.integer "role", default: 0, null: false
    t.bigint "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "position"
    t.bigint "team_id"
    t.string "auth_token"
    t.string "username", null: false
    t.string "phone_number"
    t.boolean "receive_email_notifications", default: true, null: false
    t.datetime "reset_password_sent_at"
    t.bigint "department_id"
    t.string "reset_password_token", limit: 64
    t.string "new_reset_password_token", limit: 128
    t.index ["department_id"], name: "index_users_on_department_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["new_reset_password_token"], name: "index_users_on_new_reset_password_token", unique: true
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["reset_password_sent_at"], name: "index_users_on_reset_password_sent_at_when_token_present", where: "(reset_password_token IS NOT NULL)"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username", "organization_id"], name: "index_users_on_username_and_organization_id", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "whodunnit"
    t.datetime "created_at"
    t.bigint "item_id", null: false
    t.string "item_type", null: false
    t.string "event", null: false
    t.text "object"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "business_hours", "organizations"
  add_foreign_key "comments", "tickets"
  add_foreign_key "comments", "users"
  add_foreign_key "departments", "organizations"
  add_foreign_key "notifications", "organizations"
  add_foreign_key "notifications", "users"
  add_foreign_key "problems", "tickets"
  add_foreign_key "problems", "users"
  add_foreign_key "settings", "organizations"
  add_foreign_key "sla_policies", "organizations"
  add_foreign_key "teams", "organizations"
  add_foreign_key "tickets", "departments"
  add_foreign_key "tickets", "organizations"
  add_foreign_key "tickets", "sla_policies"
  add_foreign_key "tickets", "teams"
  add_foreign_key "tickets", "users"
  add_foreign_key "tickets", "users", column: "assignee_id"
  add_foreign_key "tickets", "users", column: "requester_id"
  add_foreign_key "users", "departments"
  add_foreign_key "users", "organizations"
  add_foreign_key "users", "teams"
end
