class ChangePriorityColumnTypeInTickets < ActiveRecord::Migration[7.1]
  def change
    change_column :tickets, :priority, :integer, using: 'priority::integer'
  end
end
