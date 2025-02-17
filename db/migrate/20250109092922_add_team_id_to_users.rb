class AddTeamIdToUsers < ActiveRecord::Migration[7.1]
  def change
    # Add the team_id column only if it doesn't already exist
    unless column_exists?(:users, :team_id)
      add_column :users, :team_id, :bigint
    end

    # Add foreign key only if the column exists and the referenced table exists
    if column_exists?(:users, :team_id) && table_exists?(:teams)
      add_foreign_key :users, :teams
    end
  end
end