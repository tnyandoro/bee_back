class AddNotNullConstraintsToProblems < ActiveRecord::Migration[7.1]
  def change
    change_column_null :problems, :organization_id, false
    change_column_null :problems, :ticket_id, false
    change_column_null :problems, :user_id, false
  end
end
