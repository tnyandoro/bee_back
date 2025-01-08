class UpdateTicketsTable < ActiveRecord::Migration[7.1]
  def up
    # Remove old columns (if necessary)
    if column_exists?(:tickets, :user_id)
      remove_column :tickets, :user_id, :bigint
    end

    # Add new columns
    add_column :tickets, :ticket_number, :string, null: false
    add_column :tickets, :ticket_type, :string, null: false
    add_column :tickets, :urgency, :string
    add_column :tickets, :priority, :string
    add_column :tickets, :impact, :string
    add_column :tickets, :assignee_id, :bigint
    add_column :tickets, :team_id, :bigint
    add_column :tickets, :requester_id, :bigint
    add_column :tickets, :reported_at, :datetime
    add_column :tickets, :category, :string
    add_column :tickets, :caller_name, :string
    add_column :tickets, :caller_surname, :string
    add_column :tickets, :caller_email, :string
    add_column :tickets, :caller_phone, :string
    add_column :tickets, :customer, :string
    add_column :tickets, :source, :string

    # Add indexes
    add_index :tickets, :ticket_number, unique: true

    # Add foreign keys (only if the referenced tables exist)
    if table_exists?(:users)
      add_foreign_key :tickets, :users, column: :assignee_id
      add_foreign_key :tickets, :users, column: :requester_id
    end

    if table_exists?(:teams)
      add_foreign_key :tickets, :teams
    end
  end

  # def down
  #   # Remove foreign keys (only if they exist)
  #   if foreign_key_exists?(:tickets, column: :assignee_id)
  #     remove_foreign_key :tickets, column: :assignee_id
  #   end

  #   if foreign_key_exists?(:tickets, column: :requester_id)
  #     remove_foreign_key :tickets, column: :requester_id
  #   end

  #   if foreign_key_exists?(:tickets, :teams)
  #     remove_foreign_key :tickets, :teams
  #   end

  #   # Remove indexes
  #   if index_exists?(:tickets, :ticket_number)
  #     remove_index :tickets, :ticket_number
  #   end

  #   # Remove new columns
  #   remove_column :tickets, :ticket_number, :string
  #   remove_column :tickets, :ticket_type, :string
  #   remove_column :tickets, :urgency, :string
  #   remove_column :tickets, :priority, :string
  #   remove_column :tickets, :impact, :string
  #   remove_column :tickets, :assignee_id, :bigint
  #   remove_column :tickets, :team_id, :bigint
  #   remove_column :tickets, :requester_id, :bigint
  #   remove_column :tickets, :reported_at, :datetime
  #   remove_column :tickets, :category, :string
  #   remove_column :tickets, :caller_name, :string
  #   remove_column :tickets, :caller_surname, :string
  #   remove_column :tickets, :caller_email, :string
  #   remove_column :tickets, :caller_phone, :string
  #   remove_column :tickets, :customer, :string
  #   remove_column :tickets, :source, :string

  #   # Add back the old column (if necessary)
  #   unless column_exists?(:tickets, :user_id)
  #     add_column :tickets, :user_id, :bigint
  #   end
  # end

  def down
    # Remove foreign keys (only if they exist)
    if foreign_key_exists?(:tickets, column: :assignee_id)
      remove_foreign_key :tickets, column: :assignee_id
    end
  
    if foreign_key_exists?(:tickets, column: :requester_id)
      remove_foreign_key :tickets, column: :requester_id
    end
  
    if foreign_key_exists?(:tickets, :teams)
      remove_foreign_key :tickets, :teams
    end
  
    # Remove indexes (only if they exist)
    if index_exists?(:tickets, :ticket_number)
      remove_index :tickets, :ticket_number
    end
  
    # Remove new columns (only if they exist)
    if column_exists?(:tickets, :ticket_number)
      remove_column :tickets, :ticket_number, :string
    end
  
    if column_exists?(:tickets, :ticket_type)
      remove_column :tickets, :ticket_type, :string
    end
  
    if column_exists?(:tickets, :urgency)
      remove_column :tickets, :urgency, :string
    end
  
    if column_exists?(:tickets, :priority)
      remove_column :tickets, :priority, :string
    end
  
    if column_exists?(:tickets, :impact)
      remove_column :tickets, :impact, :string
    end
  
    if column_exists?(:tickets, :assignee_id)
      remove_column :tickets, :assignee_id, :bigint
    end
  
    if column_exists?(:tickets, :team_id)
      remove_column :tickets, :team_id, :bigint
    end
  
    if column_exists?(:tickets, :requester_id)
      remove_column :tickets, :requester_id, :bigint
    end
  
    if column_exists?(:tickets, :reported_at)
      remove_column :tickets, :reported_at, :datetime
    end
  
    if column_exists?(:tickets, :category)
      remove_column :tickets, :category, :string
    end
  
    if column_exists?(:tickets, :caller_name)
      remove_column :tickets, :caller_name, :string
    end
  
    if column_exists?(:tickets, :caller_surname)
      remove_column :tickets, :caller_surname, :string
    end
  
    if column_exists?(:tickets, :caller_email)
      remove_column :tickets, :caller_email, :string
    end
  
    if column_exists?(:tickets, :caller_phone)
      remove_column :tickets, :caller_phone, :string
    end
  
    if column_exists?(:tickets, :customer)
      remove_column :tickets, :customer, :string
    end
  
    if column_exists?(:tickets, :source)
      remove_column :tickets, :source, :string
    end
  
    # Add back the old column (if necessary)
    unless column_exists?(:tickets, :user_id)
      add_column :tickets, :user_id, :bigint
    end
  end
end
