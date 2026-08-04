class CreateMerchantsAndAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :merchants do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :legal_name, null: false
      t.string :document, null: false
      t.string :status, null: false, default: "active"

      t.timestamps
    end

    add_index :merchants, :document, unique: true

    create_table :accounts do |t|
      t.references :merchant, null: false, foreign_key: true, index: { unique: true }
      t.string :currency, null: false, default: "BRL"
      t.bigint :available_balance_cents, null: false, default: 0
      t.bigint :pending_balance_cents, null: false, default: 0

      t.timestamps
    end

    add_check_constraint :accounts, "available_balance_cents >= 0",
      name: "accounts_available_balance_cents_non_negative"
    add_check_constraint :accounts, "pending_balance_cents >= 0",
      name: "accounts_pending_balance_cents_non_negative"
  end
end
