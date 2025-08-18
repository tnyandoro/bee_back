class AddTokenExpiresAtToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :token_expires_at, :datetime
  end
end
