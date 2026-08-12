class CreateLedgerEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :ledger_entries do |t|
      t.references :account, null: false, foreign_key: true
      t.references :charge, foreign_key: true
      t.bigint :refund_id
      t.string :entry_type, null: false
      t.string :direction, null: false
      t.bigint :amount_cents, null: false
      t.string :currency, null: false, default: "BRL"
      t.string :balance_bucket, null: false
      t.string :description
      t.datetime :created_at, null: false
    end

    add_index :ledger_entries, [ :account_id, :created_at ]
    add_index :ledger_entries, :refund_id

    add_check_constraint :ledger_entries, "amount_cents > 0", name: "ledger_entries_amount_cents_positive"
  end
end
