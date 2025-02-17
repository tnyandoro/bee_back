class ChangeStatusColumnTypeInTickets < ActiveRecord::Migration[7.1]
  def up
    # Step 1: Add a temporary column to store the string values
    add_column :tickets, :status_temp, :string

    # Step 2: Map integer values to string values
    Ticket.reset_column_information
    Ticket.find_each do |ticket|
      case ticket.status
      when 0
        ticket.update(status_temp: "open")
      when 1
        ticket.update(status_temp: "pending")
      when 2
        ticket.update(status_temp: "resolved")
      when 3
        ticket.update(status_temp: "closed")
      else
        ticket.update(status_temp: "open") # Default value
      end
    end

    # Step 3: Remove the old status column
    remove_column :tickets, :status

    # Step 4: Rename the temporary column to status
    rename_column :tickets, :status_temp, :status
  end

  def down
    # Step 1: Add a temporary column to store the integer values
    add_column :tickets, :status_temp, :integer

    # Step 2: Map string values back to integer values
    Ticket.reset_column_information
    Ticket.find_each do |ticket|
      case ticket.status
      when "open"
        ticket.update(status_temp: 0)
      when "pending"
        ticket.update(status_temp: 1)
      when "resolved"
        ticket.update(status_temp: 2)
      when "closed"
        ticket.update(status_temp: 3)
      else
        ticket.update(status_temp: 0) # Default value
      end
    end

    # Step 3: Remove the status column
    remove_column :tickets, :status

    # Step 4: Rename the temporary column to status
    rename_column :tickets, :status_temp, :status
  end
end