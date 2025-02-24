class ConvertUrgencyImpactToInteger < ActiveRecord::Migration[7.1]
  def up
    # Rename existing columns
    rename_column :tickets, :urgency, :old_urgency
    rename_column :tickets, :impact, :old_impact

    # Add new integer columns
    add_column :tickets, :urgency, :integer
    add_column :tickets, :impact, :integer

    # Migrate data using SQL
    execute <<-SQL.squish
      UPDATE tickets 
      SET 
        urgency = CASE old_urgency 
          WHEN 'Low' THEN 0 
          WHEN 'Medium' THEN 1 
          WHEN 'High' THEN 2 
          ELSE 0 
        END,
        impact = CASE old_impact 
          WHEN 'Low' THEN 0 
          WHEN 'Medium' THEN 1 
          WHEN 'High' THEN 2 
          ELSE 0 
        END
    SQL

    # Remove old columns
    remove_column :tickets, :old_urgency
    remove_column :tickets, :old_impact

    # Add constraints
    change_column_null :tickets, :urgency, false
    change_column_null :tickets, :impact, false
  end

  def down
    # Reverse the process
    rename_column :tickets, :urgency, :new_urgency
    rename_column :tickets, :impact, :new_impact

    add_column :tickets, :urgency, :string
    add_column :tickets, :impact, :string

    execute <<-SQL.squish
      UPDATE tickets 
      SET 
        urgency = CASE new_urgency 
          WHEN 0 THEN 'Low' 
          WHEN 1 THEN 'Medium' 
          WHEN 2 THEN 'High' 
          ELSE 'Low' 
        END,
        impact = CASE new_impact 
          WHEN 0 THEN 'Low' 
          WHEN 1 THEN 'Medium' 
          WHEN 2 THEN 'High' 
          ELSE 'Low' 
        END
    SQL

    remove_column :tickets, :new_urgency
    remove_column :tickets, :new_impact
  end
end