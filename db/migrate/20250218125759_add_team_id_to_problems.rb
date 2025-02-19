class AddTeamIdToProblems < ActiveRecord::Migration[7.1]
  def change
    add_column :problems, :team_id, :integer
  end
end
