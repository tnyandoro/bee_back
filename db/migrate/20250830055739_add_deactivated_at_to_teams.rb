class AddDeactivatedAtToTeams < ActiveRecord::Migration[7.0]
  def change
    add_column :teams, :deactivated_at, :datetime
  end
end
