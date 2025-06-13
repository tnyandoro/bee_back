# frozen_string_literal: true
class SafelyUpdateResetPasswordTokenUsers < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    # Add new column with length limit
    add_column :users, :new_reset_password_token, :string, limit: 64

    # Backfill data
    User.where.not(reset_password_token: nil).find_each do |user|
      token = user.reset_password_token
      token = token[0, 64] if token && token.length > 64
      user.update_columns(new_reset_password_token: token)
    end

    # Ensure uniqueness in new column
    duplicate_tokens = User.group(:new_reset_password_token)
                          .having('COUNT(*) > 1')
                          .where.not(new_reset_password_token: nil)
                          .pluck(:new_reset_password_token)
    
    duplicate_tokens.each do |token|
      users = User.where(new_reset_password_token: token).order(:id)
      users[1..-1].each do |user|
        user.update_columns(new_reset_password_token: SecureRandom.hex(32)) # 64 chars
      end
    end

    # Add unique index to new column
    safety_assured do
      add_index :users, :new_reset_password_token, unique: true
    end

    # Drop old column and rename new one
    safety_assured do
      remove_index :users, :reset_password_token
      remove_column :users, :reset_password_token
      rename_column :users, :new_reset_password_token, :reset_password_token
    end
  end

  def down
    # Reverse steps
    add_column :users, :old_reset_password_token, :string
    User.where.not(reset_password_token: nil).find_each do |user|
      user.update_columns(old_reset_password_token: user.reset_password_token)
    end
    remove_index :users, :reset_password_token
    remove_column :users, :reset_password_token
    rename_column :users, :old_reset_password_token, :reset_password_token
    add_index :users, :reset_password_token, unique: true
  end
end