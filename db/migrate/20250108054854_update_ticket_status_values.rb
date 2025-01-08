class UpdateTicketStatusValues < ActiveRecord::Migration[7.1]
  def up
    # Set default value for null statuses
    Ticket.where(status: nil).update_all(status: "open")

    # Map old integer values to new string values
    Ticket.where(status: "0").update_all(status: "open")
    Ticket.where(status: "1").update_all(status: "pending")
    Ticket.where(status: "2").update_all(status: "resolved")
    Ticket.where(status: "3").update_all(status: "closed")
  end

  def down
    # Revert the changes if needed
    Ticket.where(status: "open").update_all(status: "0")
    Ticket.where(status: "pending").update_all(status: "1")
    Ticket.where(status: "resolved").update_all(status: "2")
    Ticket.where(status: "closed").update_all(status: "3")
  end
end