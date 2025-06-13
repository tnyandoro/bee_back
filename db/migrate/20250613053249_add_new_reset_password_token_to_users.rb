class AddNewResetPasswordTokenToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :new_reset_password_token, :string, limit: 128
  end
end
