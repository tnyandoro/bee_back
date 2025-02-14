class DropUserNotifications < ActiveRecord::Migration[7.1]
  def change
    drop_table :user_notifications
  end
end
