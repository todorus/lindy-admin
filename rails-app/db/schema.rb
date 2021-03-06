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

ActiveRecord::Schema.define(version: 20180219080040) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "courses", force: :cascade do |t|
    t.string   "title",              null: false
    t.text     "description",        null: false
    t.date     "registration_start", null: false
    t.date     "registration_end",   null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "mailings", force: :cascade do |t|
    t.integer  "registration_id"
    t.integer  "status"
    t.string   "remote_id"
    t.string   "remote_template_id"
    t.json     "arguments"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "label"
    t.integer  "target",             default: 1
    t.index ["registration_id"], name: "index_mailings_on_registration_id", using: :btree
  end

  create_table "members", force: :cascade do |t|
    t.string   "firstname",  null: false
    t.string   "lastname",   null: false
    t.string   "email",      null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_members_on_email", unique: true, using: :btree
  end

  create_table "payments", force: :cascade do |t|
    t.integer  "registration_id"
    t.string   "remote_id"
    t.string   "payment_url"
    t.integer  "status",          default: 0
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.index ["registration_id"], name: "index_payments_on_registration_id", using: :btree
  end

  create_table "registrations", force: :cascade do |t|
    t.integer  "member_id"
    t.integer  "course_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "role",       default: false, null: false
    t.integer  "ticket_id"
    t.integer  "status",     default: 0
    t.json     "additional"
    t.index ["course_id"], name: "index_registrations_on_course_id", using: :btree
    t.index ["member_id", "course_id"], name: "index_registrations_on_member_id_and_course_id", unique: true, using: :btree
    t.index ["member_id"], name: "index_registrations_on_member_id", using: :btree
    t.index ["ticket_id"], name: "index_registrations_on_ticket_id", using: :btree
  end

  create_table "settings", force: :cascade do |t|
    t.string   "var",                   null: false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", limit: 30
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.index ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true, using: :btree
  end

  create_table "tenants", force: :cascade do |t|
    t.string   "label"
    t.string   "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tickets", force: :cascade do |t|
    t.integer  "course_id"
    t.string   "label"
    t.integer  "price_cents",    default: 0,     null: false
    t.string   "price_currency", default: "EUR", null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.index ["course_id"], name: "index_tickets_on_course_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.integer  "role",                   default: 1
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "tenant_id"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["tenant_id"], name: "index_users_on_tenant_id", using: :btree
  end

  add_foreign_key "mailings", "registrations"
  add_foreign_key "payments", "registrations", on_delete: :cascade
  add_foreign_key "registrations", "courses", on_delete: :cascade
  add_foreign_key "registrations", "members", on_delete: :cascade
  add_foreign_key "registrations", "tickets", on_delete: :cascade
  add_foreign_key "tickets", "courses", on_delete: :cascade
end
