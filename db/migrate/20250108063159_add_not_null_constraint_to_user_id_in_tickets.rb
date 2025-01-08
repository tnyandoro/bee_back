class AddNotNullConstraintToUserIdInTickets < ActiveRecord::Migration[7.1]
  def change
    # Ensure user_id is not null
    change_column_null :tickets, :user_id, false
  end
end