class CreateCharges < ActiveRecord::Migration[8.1]
  def change
    create_table :charges do |t|
      t.references :merchant, null: false, foreign_key: true
      t.string :public_id, null: false
      t.bigint :amount_cents, null: false
      t.string :currency, null: false, default: "BRL"
      t.string :status, null: false, default: "pending"
      t.string :payment_method, null: false
      t.string :provider, null: false, default: "mock"
      t.string :provider_ref
      t.string :description
      t.string :customer_email
      t.string :customer_document
      t.jsonb :metadata, null: false, default: {}
      t.datetime :succeeded_at
      t.datetime :failed_at
      t.datetime :canceled_at

      t.timestamps
    end

    add_index :charges, :public_id, unique: true
    add_index :charges, :status
    add_index :charges, [ :merchant_id, :created_at ]
    add_index :charges, [ :provider, :provider_ref ],
      unique: true,
      where: "provider_ref IS NOT NULL",
      name: "index_charges_on_provider_and_provider_ref"

    add_check_constraint :charges, "amount_cents > 0", name: "charges_amount_cents_positive"
  end
end
