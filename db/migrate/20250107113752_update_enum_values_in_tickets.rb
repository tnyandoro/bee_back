class UpdateEnumValuesInTickets < ActiveRecord::Migration[7.1]
  # def up
  #   # Remove old columns (if necessary)
  #   if column_exists?(:tickets, :user_id)
  #     remove_column :tickets, :user_id, :bigint
  #   end
  
  #   # Add new columns (only if they don't exist)
  #   unless column_exists?(:tickets, :ticket_number)
  #     add_column :tickets, :ticket_number, :string, null: false
  #   end
  
  #   unless column_exists?(:tickets, :ticket_type)
  #     add_column :tickets, :ticket_type, :string, null: false
  #   end
  
  #   unless column_exists?(:tickets, :urgency)
  #     add_column :tickets, :urgency, :string
  #   end
  
  #   unless column_exists?(:tickets, :priority)
  #     add_column :tickets, :priority, :string
  #   end
  
  #   unless column_exists?(:tickets, :impact)
  #     add_column :tickets, :impact, :string
  #   end
  
  #   unless column_exists?(:tickets, :assignee_id)
  #     add_column :tickets, :assignee_id, :bigint
  #   end
  
  #   unless column_exists?(:tickets, :team_id)
  #     add_column :tickets, :team_id, :bigint
  #   end
  
  #   unless column_exists?(:tickets, :requester_id)
  #     add_column :tickets, :requester_id, :bigint
  #   end
  
  #   unless column_exists?(:tickets, :reported_at)
  #     add_column :tickets, :reported_at, :datetime
  #   end
  
  #   unless column_exists?(:tickets, :category)
  #     add_column :tickets, :category, :string
  #   end
  
  #   unless column_exists?(:tickets, :caller_name)
  #     add_column :tickets, :caller_name, :string
  #   end
  
  #   unless column_exists?(:tickets, :caller_surname)
  #     add_column :tickets, :caller_surname, :string
  #   end
  
  #   unless column_exists?(:tickets, :caller_email)
  #     add_column :tickets, :caller_email, :string
  #   end
  
  #   unless column_exists?(:tickets, :caller_phone)
  #     add_column :tickets, :caller_phone, :string
  #   end
  
  #   unless column_exists?(:tickets, :customer)
  #     add_column :tickets, :customer, :string
  #   end
  
  #   unless column_exists?(:tickets, :source)
  #     add_column :tickets, :source, :string
  #   end
  
  #   # Add indexes (only if they don't exist)
  #   unless index_exists?(:tickets, :ticket_number)
  #     add_index :tickets, :ticket_number, unique: true
  #   end
  
  #   # Add foreign keys (only if the referenced tables exist)
  #   if table_exists?(:users)
  #     unless foreign_key_exists?(:tickets, column: :assignee_id)
  #       add_foreign_key :tickets, :users, column: :assignee_id
  #     end
  
  #     unless foreign_key_exists?(:tickets, column: :requester_id)
  #       add_foreign_key :tickets, :users, column: :requester_id
  #     end
  #   end
  
  #   if table_exists?(:teams)
  #     unless foreign_key_exists?(:tickets, :teams)
  #       add_foreign_key :tickets, :teams
  #     end
  #   end
  # end
  def up
    # Remove old columns (if necessary)
    if column_exists?(:tickets, :user_id)
      remove_column :tickets, :user_id, :bigint
    end
  
    # Add new columns (only if they don't exist)
    unless column_exists?(:tickets, :ticket_number)
      add_column :tickets, :ticket_number, :string, null: false
    end
  
    unless column_exists?(:tickets, :ticket_type)
      add_column :tickets, :ticket_type, :string, null: false
    end
  
    unless column_exists?(:tickets, :urgency)
      add_column :tickets, :urgency, :string
    end
  
    unless column_exists?(:tickets, :priority)
      add_column :tickets, :priority, :string
    end
  
    unless column_exists?(:tickets, :impact)
      add_column :tickets, :impact, :string
    end
  
    unless column_exists?(:tickets, :assignee_id)
      add_column :tickets, :assignee_id, :bigint
    end
  
    unless column_exists?(:tickets, :team_id)
      add_column :tickets, :team_id, :bigint
    end
  
    unless column_exists?(:tickets, :requester_id)
      add_column :tickets, :requester_id, :bigint
    end
  
    unless column_exists?(:tickets, :reported_at)
      add_column :tickets, :reported_at, :datetime
    end
  
    unless column_exists?(:tickets, :category)
      add_column :tickets, :category, :string
    end
  
    unless column_exists?(:tickets, :caller_name)
      add_column :tickets, :caller_name, :string
    end
  
    unless column_exists?(:tickets, :caller_surname)
      add_column :tickets, :caller_surname, :string
    end
  
    unless column_exists?(:tickets, :caller_email)
      add_column :tickets, :caller_email, :string
    end
  
    unless column_exists?(:tickets, :caller_phone)
      add_column :tickets, :caller_phone, :string
    end
  
    unless column_exists?(:tickets, :customer)
      add_column :tickets, :customer, :string
    end
  
    unless column_exists?(:tickets, :source)
      add_column :tickets, :source, :string
    end
  
    # Add indexes (only if they don't exist)
    unless index_exists?(:tickets, :ticket_number)
      add_index :tickets, :ticket_number, unique: true
    end
  
    # Add foreign keys (only if the referenced tables exist)
    if table_exists?(:users)
      unless foreign_key_exists?(:tickets, column: :assignee_id)
        add_foreign_key :tickets, :users, column: :assignee_id
      end
  
      unless foreign_key_exists?(:tickets, column: :requester_id)
        add_foreign_key :tickets, :users, column: :requester_id
      end
    end
  
    if table_exists?(:teams)
      unless foreign_key_exists?(:tickets, :teams)
        add_foreign_key :tickets, :teams
      end
    end
  end

  def down
    # Revert urgency values
    if column_exists?(:tickets, :urgency)
      execute <<-SQL
        UPDATE tickets
        SET urgency = 'High'
        WHERE urgency = 'urgent_high';
      SQL

      execute <<-SQL
        UPDATE tickets
        SET urgency = 'Medium'
        WHERE urgency = 'urgent_medium';
      SQL

      execute <<-SQL
        UPDATE tickets
        SET urgency = 'Low'
        WHERE urgency = 'urgent_low';
      SQL
    end

    # Revert impact values
    if column_exists?(:tickets, :impact)
      execute <<-SQL
        UPDATE tickets
        SET impact = 'High'
        WHERE impact = 'impact_high';
      SQL

      execute <<-SQL
        UPDATE tickets
        SET impact = 'Medium'
        WHERE impact = 'impact_medium';
      SQL

      execute <<-SQL
        UPDATE tickets
        SET impact = 'Low'
        WHERE impact = 'impact_low';
      SQL
    end
  end
end
