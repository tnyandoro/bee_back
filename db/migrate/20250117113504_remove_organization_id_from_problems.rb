class RemoveOrganizationIdFromProblems < ActiveRecord::Migration[7.1]
  def up
    # Remove the organization_id column only if it exists
    if column_exists?(:problems, :organization_id)
      remove_column :problems, :organization_id, :bigint
    end
  end

  def down
    # Add the organization_id column only if it doesn't already exist
    unless column_exists?(:problems, :organization_id)
      add_column :problems, :organization_id, :bigint
    end
  end
end