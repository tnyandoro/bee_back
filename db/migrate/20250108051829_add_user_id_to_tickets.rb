class AddUserIdToTickets < ActiveRecord::Migration[7.1]
  def change
    add_column :tickets, :user_id, :bigint
  end
end
