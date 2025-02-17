class AddUserIdToTickets < ActiveRecord::Migration[7.1]
  def change
    add_column :tickets, :user_id, :bigint
    add_foreign_key :tickets, :users
    add_index :tickets, :user_id
  end
end
