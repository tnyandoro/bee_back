class AddReceiveEmailNotificationsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :receive_email_notifications, :boolean, default: true, null: false
  end
end