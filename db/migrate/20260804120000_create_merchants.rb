class CreateMerchants < ActiveRecord::Migration[8.1]
  def change
    create_table :merchants do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.string :legal_name, null: false
      t.string :document, null: false
      t.string :status, null: false, default: "active"

      t.timestamps
    end

    add_index :merchants, :document, unique: true
  end
end
