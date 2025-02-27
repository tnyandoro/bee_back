
class FinalizeUrgencyImpactConversion < ActiveRecord::Migration[7.1]
  def up
    safety_assured do
      change_column :tickets, :urgency, :integer, using: 'urgency::integer'
      change_column :tickets, :impact, :integer, using: 'impact::integer'
      change_column_default :tickets, :urgency, 0
      change_column_default :tickets, :impact, 0
      change_column_null :tickets, :urgency, false
      change_column_null :tickets, :impact, false
    end
  end

  def down
    change_column :tickets, :urgency, :string
    change_column :tickets, :impact, :string
  end
end