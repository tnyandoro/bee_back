# Version: 0.1
class AddColumnsToBusinessHours < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      change_table :business_hours do |t|
        t.references :organization, null: false, foreign_key: true
        t.integer :day_of_week, null: false
        t.time :start_time, null: false
        t.time :end_time, null: false
      end

      add_index :business_hours, [:organization_id, :day_of_week], unique: true
    end
  end
end