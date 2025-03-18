class AddResolutionFieldsToTickets < ActiveRecord::Migration[7.1]
  def change
    add_column :tickets, :resolved_at, :datetime
    add_column :tickets, :resolution_note, :text
  end
end
