class AddTicketForeignKeyToNotifications < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_foreign_key :notifications, :tickets, validate: false
  end
end