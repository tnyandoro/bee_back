class AddNotNullConstraintsToProblems < ActiveRecord::Migration[7.1]
  def change
    # Add the organization_id column if it doesn't already exist
    unless column_exists?(:problems, :organization_id)
      add_column :problems, :organization_id, :bigint
    end

    # Ensure all existing rows have a valid organization_id
    default_organization = Organization.first # Replace with a valid organization
    if default_organization
      Problem.where(organization_id: nil).update_all(organization_id: default_organization.id)
    else
      raise "Default organization not found. Please create an organization before running this migration."
    end

    # Add the NOT NULL constraint
    change_column_null :problems, :organization_id, false
  end
end