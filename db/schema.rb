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

ActiveRecord::Schema[8.1].define(version: 2026_08_11_180001) do
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

  create_table "charges", force: :cascade do |t|
    t.bigint "amount_cents", null: false
    t.datetime "canceled_at"
    t.datetime "created_at", null: false
    t.string "currency", default: "BRL", null: false
    t.string "customer_document"
    t.string "customer_email"
    t.string "description"
    t.datetime "failed_at"
    t.bigint "merchant_id", null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "payment_method", null: false
    t.string "provider", default: "mock", null: false
    t.string "provider_ref"
    t.string "public_id", null: false
    t.string "status", default: "pending", null: false
    t.datetime "succeeded_at"
    t.datetime "updated_at", null: false
    t.index ["merchant_id", "created_at"], name: "index_charges_on_merchant_id_and_created_at"
    t.index ["merchant_id"], name: "index_charges_on_merchant_id"
    t.index ["provider", "provider_ref"], name: "index_charges_on_provider_and_provider_ref", unique: true, where: "(provider_ref IS NOT NULL)"
    t.index ["public_id"], name: "index_charges_on_public_id", unique: true
    t.index ["status"], name: "index_charges_on_status"
    t.check_constraint "amount_cents > 0", name: "charges_amount_cents_positive"
  end

  create_table "ledger_entries", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "amount_cents", null: false
    t.string "balance_bucket", null: false
    t.bigint "charge_id"
    t.datetime "created_at", null: false
    t.string "currency", default: "BRL", null: false
    t.string "description"
    t.string "direction", null: false
    t.string "entry_type", null: false
    t.bigint "refund_id"
    t.index ["account_id", "created_at"], name: "index_ledger_entries_on_account_id_and_created_at"
    t.index ["account_id"], name: "index_ledger_entries_on_account_id"
    t.index ["charge_id"], name: "index_ledger_entries_on_charge_id"
    t.index ["refund_id"], name: "index_ledger_entries_on_refund_id"
    t.check_constraint "amount_cents > 0", name: "ledger_entries_amount_cents_positive"
  end

  create_table "merchants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "document", null: false
    t.string "legal_name", null: false
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["document"], name: "index_merchants_on_document", unique: true
    t.index ["user_id"], name: "index_merchants_on_user_id"
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
  add_foreign_key "charges", "merchants"
  add_foreign_key "ledger_entries", "accounts"
  add_foreign_key "ledger_entries", "charges"
  add_foreign_key "merchants", "users"
  add_foreign_key "refresh_tokens", "users"
end
