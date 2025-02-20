class AddCreatorIdToProblems < ActiveRecord::Migration[7.1]
  def change
    unless column_exists? :problems, :creator_id
      add_column :problems, :creator_id, :integer
    end
  end
end