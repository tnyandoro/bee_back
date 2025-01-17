class CreateTeams < ActiveRecord::Migration[7.1]
  def change
    # Create the teams table only if it doesn't already exist
    unless table_exists?(:teams)
      create_table :teams do |t|
        t.string :name
        t.bigint :organization_id, null: false
        t.timestamps
      end

      # Add foreign key only if the referenced table exists
      if table_exists?(:organizations)
        add_foreign_key :teams, :organizations
      end
    end
  end
end