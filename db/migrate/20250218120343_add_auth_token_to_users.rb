class AddAuthTokenToUsers < ActiveRecord::Migration[7.1]
  def change
    unless column_exists? :users, :auth_token
      add_column :users, :auth_token, :string
    end
  end
end