class AddTeamIdToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :team_id, :bigint
    add_foreign_key :users, :teams
    add_index :users, :team_id
  end
end
