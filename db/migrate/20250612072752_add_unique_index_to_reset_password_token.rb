class AddUniqueIndexToResetPasswordToken < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    # Clear existing tokens to prevent duplicate violations
    safety_assured do
      execute <<-SQL
        UPDATE users
        SET reset_password_token = NULL, reset_password_sent_at = NULL
        WHERE reset_password_token IS NOT NULL
      SQL
    end

    # Add unique index concurrently to avoid locking
    add_index :users, :reset_password_token, unique: true, algorithm: :concurrently

    # Enforce null: false on reset_password_sent_at
    safety_assured do
      # Update existing records with a default timestamp
      execute <<-SQL
        UPDATE users
        SET reset_password_sent_at = CURRENT_TIMESTAMP
        WHERE reset_password_sent_at IS NULL AND reset_password_token IS NOT NULL
      SQL

      change_column_null :users, :reset_password_sent_at, false, Time.current
    end
  end
end