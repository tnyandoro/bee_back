class AddRelatedIncidentIdToProblems < ActiveRecord::Migration[7.1]
  def change
    add_column :problems, :related_incident_id, :integer
  end
end
