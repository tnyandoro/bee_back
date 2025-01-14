class AddIndexToUserIdInTickets < ActiveRecord::Migration[7.1]
  def change
    # Add an index to the user_id column in the tickets table
    add_index :tickets, :user_id
  end
end