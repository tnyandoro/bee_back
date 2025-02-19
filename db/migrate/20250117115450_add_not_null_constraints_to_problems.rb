class AddNotNullConstraintsToProblems < ActiveRecord::Migration[7.1]
  def change
    # Add the organization_id column if it doesn't already exist
    unless column_exists?(:problems, :organization_id)
      add_column :problems, :organization_id, :bigint
    end

    # Create a default organization if none exists, bypassing validations
    org = Organization.new(name: "Default Organization", email: "default@example.com")
    org.save(validate: false) # Skips validation

    # Assign default organization_id to existing problem records
    Problem.where(organization_id: nil).update_all(organization_id: org.id)

    # Add the NOT NULL constraint
    change_column_null :problems, :organization_id, false
  end
end