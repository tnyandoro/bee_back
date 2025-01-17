class RemoveOrganizationIdFromProblems < ActiveRecord::Migration[7.1]
  def change
    remove_column :problems, :organization_id, :bigint
  end
end