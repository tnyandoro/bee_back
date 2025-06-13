class SafelyAddUniqueIndexToNewResetPasswordToken < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :users,
              :new_reset_password_token,
              unique: true,
              algorithm: :concurrently
  end

  def down
    remove_index :users,
                 column: :new_reset_password_token,
                 algorithm: :concurrently
  end
end
