# Version: 0.1
class AddNotifiableToNotifications < ActiveRecord::Migration[7.0]
  def change
    # Change null: false to null: true to allow null values
    add_reference :notifications, :notifiable, polymorphic: true, null: true, index: true
  end
end