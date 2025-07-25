class CreateTickets < ActiveRecord::Migration[7.1]
  def change
    create_table :tickets do |t|
      t.string :title, null: false
      t.text :description
      t.string :ticket_number, null: false, index: { unique: true }
      t.string :ticket_type
      t.datetime :reported_at
      t.string :category
      t.string :caller_name
      t.string :caller_surname
      t.string :caller_email
      t.string :caller_phone
      t.string :customer
      t.string :source
      t.integer :status
      t.integer :urgency
      t.integer :impact
      t.integer :priority
      t.integer :calculated_priority
      t.datetime :response_due_at
      t.datetime :resolution_due_at
      t.boolean :sla_breached, default: false

      t.references :organization, null: false, foreign_key: true
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.references :requester, null: false, foreign_key: { to_table: :users }
      t.references :assignee, foreign_key: { to_table: :users }
      t.references :team, foreign_key: true
      t.references :sla_policy, foreign_key: true
      t.references :department, foreign_key: true

      t.timestamps
    end
  end
end
