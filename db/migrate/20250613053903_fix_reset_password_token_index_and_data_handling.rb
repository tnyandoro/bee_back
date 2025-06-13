class FixResetPasswordTokenIndexAndDataHandling < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    # Remove old index concurrently if exists
    remove_index :users, :reset_password_token, algorithm: :concurrently rescue nil

    # Recreate unique index concurrently
    add_index :users, :reset_password_token, unique: true, algorithm: :concurrently

    # Fix data update using anonymous class to avoid model coupling
    users = Class.new(ActiveRecord::Base) { self.table_name = "users" }

    users.where.not(reset_password_token: nil).find_each do |user|
      token = user.reset_password_token
      token = token[0, 64] if token && token.length > 64
      user.update_columns(reset_password_token: token)
    end
  end

  def down
    remove_index :users, :reset_password_token, algorithm: :concurrently rescue nil

    add_index :users, :reset_password_token, unique: true, algorithm: :concurrently
  end
end
