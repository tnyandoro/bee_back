# frozen_string_literal: true

class CompleteNotifiableForNotifications < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    # Add notifiable_id and notifiable_type if not already present
    unless column_exists?(:notifications, :notifiable_id)
      add_column :notifications, :notifiable_id, :bigint
    end
    unless column_exists?(:notifications, :notifiable_type)
      add_column :notifications, :notifiable_type, :string
    end

    # Migrate existing ticket_id data to notifiable_id and notifiable_type
    safety_assured do
      reversible do |dir|
        dir.up do
          execute <<-SQL
            UPDATE notifications
            SET notifiable_id = ticket_id, notifiable_type = 'Ticket'
            WHERE ticket_id IS NOT NULL;
          SQL
        end
        dir.down do
          execute <<-SQL
            UPDATE notifications
            SET ticket_id = notifiable_id
            WHERE notifiable_type = 'Ticket';
          SQL
        end
      end
    end

    # Remove the ticket_id foreign key
    if foreign_key_exists?(:notifications, :tickets)
      remove_foreign_key :notifications, :tickets
    end

    # Remove ticket_id index and column
    if index_exists?(:notifications, :ticket_id)
      remove_index :notifications, name: "index_notifications_on_ticket_id", algorithm: :concurrently
    end
    if column_exists?(:notifications, :ticket_id)
      safety_assured { remove_column :notifications, :ticket_id }
    end

    # Add concurrent index for notifiable
    unless index_exists?(:notifications, [:notifiable_id, :notifiable_type])
      add_index :notifications, [:notifiable_id, :notifiable_type], 
                name: "index_notifications_on_notifiable_id_and_type", 
                algorithm: :concurrently
    end
  end
end