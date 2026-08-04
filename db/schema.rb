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

ActiveRecord::Schema[8.1].define(version: 2026_08_04_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.bigint "available_balance_cents", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "BRL", null: false
    t.bigint "merchant_id", null: false
    t.bigint "pending_balance_cents", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["merchant_id"], name: "index_accounts_on_merchant_id", unique: true
    t.check_constraint "available_balance_cents >= 0", name: "accounts_available_balance_cents_non_negative"
    t.check_constraint "pending_balance_cents >= 0", name: "accounts_pending_balance_cents_non_negative"
  end

  create_table "merchants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "document", null: false
    t.string "legal_name", null: false
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["document"], name: "index_merchants_on_document", unique: true
    t.index ["user_id"], name: "index_merchants_on_user_id", unique: true
  end

  create_table "refresh_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.datetime "revoked_at"
    t.string "token_digest", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["token_digest"], name: "index_refresh_tokens_on_token_digest", unique: true
    t.index ["user_id"], name: "index_refresh_tokens_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "cpf", null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["cpf"], name: "index_users_on_cpf", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "accounts", "merchants"
  add_foreign_key "merchants", "users"
  add_foreign_key "refresh_tokens", "users"
end
