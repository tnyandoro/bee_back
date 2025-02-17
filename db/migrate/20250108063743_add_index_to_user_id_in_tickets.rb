class AddIndexToUserIdInTickets < ActiveRecord::Migration[7.1]
  def change
    # Add the index only if it doesn't already exist
    unless index_exists?(:tickets, :user_id)
      add_index :tickets, :user_id
    end
  end
end