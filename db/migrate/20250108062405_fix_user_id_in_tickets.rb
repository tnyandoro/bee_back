class FixUserIdInTickets < ActiveRecord::Migration[7.1]
  def change
    # Ensure user_id is not null and has a foreign key constraint
    change_column_null :tickets, :user_id, false
    add_foreign_key :tickets, :users
  end
end