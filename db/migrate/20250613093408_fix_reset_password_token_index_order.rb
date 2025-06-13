class FixResetPasswordTokenIndexOrder < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    # Define anonymous class to avoid model coupling
    users = Class.new(ActiveRecord::Base) do
      self.table_name = 'users'
    end

    # Clean the data first
    users.where.not(reset_password_token: nil).find_each(batch_size: 100) do |user|
      token = user.reset_password_token
      token = token[0, 64] if token.length > 64
      user.update_columns(reset_password_token: token)
    end

    # Drop and re-add the index to ensure it enforces correct uniqueness
    remove_index :users, :reset_password_token, algorithm: :concurrently, if_exists: true
    add_index :users, :reset_password_token, unique: true, algorithm: :concurrently
  end

  def down
    remove_index :users, :reset_password_token, algorithm: :concurrently, if_exists: true
    # Optionally: re-add it non-uniquely or leave it out depending on policy
    add_index :users, :reset_password_token, unique: true, algorithm: :concurrently
  end
end
