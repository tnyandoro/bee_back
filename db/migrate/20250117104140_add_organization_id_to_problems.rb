class AddOrganizationIdToProblems < ActiveRecord::Migration[7.1]
  def change
    add_reference :problems, :organization, null: false, foreign_key: true
  end
end
