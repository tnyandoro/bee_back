class AddPositionToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :position, :string
  end
end
