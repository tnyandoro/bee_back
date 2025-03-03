class AddCalculatedPriorityToTickets < ActiveRecord::Migration[7.1]
  def change
    add_column :tickets, :calculated_priority, :integer
  end
end
