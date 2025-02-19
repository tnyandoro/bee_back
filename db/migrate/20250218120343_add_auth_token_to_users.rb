class AddAuthTokenToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :auth_token, :string
  end
end
