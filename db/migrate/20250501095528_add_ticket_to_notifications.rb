class AddTicketToNotifications < ActiveRecord::Migration[7.1]
  disable_ddl_transaction! # Allows concurrent operations

  def change
    add_column :notifications, :ticket_id, :bigint
    add_index :notifications, :ticket_id, algorithm: :concurrently
  end
end