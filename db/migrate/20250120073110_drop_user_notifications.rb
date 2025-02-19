class DropUserNotifications < ActiveRecord::Migration[7.1]
  def change
    # Check if the table exists before trying to drop it
    if table_exists?(:user_notifications)
      drop_table :user_notifications
    else
      puts "Table 'user_notifications' does not exist, skipping drop."
    end
  end
end
