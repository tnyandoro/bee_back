class AddTeamIdToProblems < ActiveRecord::Migration[7.1]
  def change
    unless column_exists? :problems, :team_id
      add_column :problems, :team_id, :integer
    end
  end
end