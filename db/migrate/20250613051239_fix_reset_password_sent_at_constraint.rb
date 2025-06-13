class FixResetPasswordSentAtConstraint < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    # Remove the NOT NULL constraint
    safety_assured do
      change_column_null :users, :reset_password_sent_at, true
    end

    # Add partial index concurrently
    add_index :users,
              :reset_password_sent_at,
              where: "reset_password_token IS NOT NULL",
              name: "index_users_on_reset_password_sent_at_when_token_present",
              algorithm: :concurrently
  end
end
