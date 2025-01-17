class AddPendingStatusToTickets < ActiveRecord::Migration[7.1]
  def change
    change_column_default :tickets, :status, from: 0, to: 6 # Optional: Set default status to "pending"
  end
end