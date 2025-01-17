class FixUserIdInTickets < ActiveRecord::Migration[7.1]
  def up
    # Step 1: Set a default user_id for existing rows where user_id is null
    default_user = User.find_by(email: 'admin@example.com') # Replace with a valid user
    if default_user
      Ticket.where(user_id: nil).update_all(user_id: default_user.id)
    else
      raise "Default user not found. Please create a user before running this migration."
    end

    # Step 2: Add the NOT NULL constraint
    change_column_null :tickets, :user_id, false
  end

  def down
    # Step 1: Remove the NOT NULL constraint
    change_column_null :tickets, :user_id, true

    # Step 2: Optionally, set user_id to null for rows that were updated
    # This step is optional and depends on your requirements
    # Ticket.where(user_id: default_user.id).update_all(user_id: nil)
  end
end
