class CreateTickets < ActiveRecord::Migration[7.1]
  def change
    create_table :tickets do |t|
      t.string :title
      t.text :description
      t.integer :status
      t.integer :priority
      t.references :user, null: false, foreign_key: true
      t.references :organization, null: false, foreign_key: true

      t.timestamps
    end
  end
end
