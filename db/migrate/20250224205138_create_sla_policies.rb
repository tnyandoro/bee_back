class CreateSlaPolicies < ActiveRecord::Migration[7.1]
  def change
    create_table :sla_policies do |t|
      t.references :organization, null: false, foreign_key: true
      t.integer :priority
      t.integer :response_time
      t.integer :resolution_time

      t.timestamps
    end
  end
end
