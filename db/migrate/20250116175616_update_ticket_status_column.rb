class UpdateTicketStatusColumn < ActiveRecord::Migration[7.0]
  def up
    # Step 1: Add a temporary integer column
    add_column :tickets, :status_new, :integer, default: 0, null: false

    # Step 2: Map existing string values to integers
    Ticket.reset_column_information
    Ticket.find_each do |ticket|
      ticket.update!(status_new: case ticket.status
                                  when 'open' then 0
                                  when 'assigned' then 1
                                  when 'escalated' then 2
                                  when 'closed' then 3
                                  when 'suspended' then 4
                                  when 'resolved' then 5
                                  else 0 # Default to 'open' if unrecognized
                                end)
    end

    # Step 3: Remove the old column and rename the new column
    remove_column :tickets, :status
    rename_column :tickets, :status_new, :status
  end

  def down
    # Step 1: Add back the string column
    add_column :tickets, :status_old, :string

    # Step 2: Map integer values back to strings
    Ticket.reset_column_information
    Ticket.find_each do |ticket|
      ticket.update!(status_old: case ticket.status
                                  when 0 then 'open'
                                  when 1 then 'assigned'
                                  when 2 then 'escalated'
                                  when 3 then 'closed'
                                  when 4 then 'suspended'
                                  when 5 then 'resolved'
                                  else 'open' # Default to 'open'
                                end)
    end

    # Step 3: Remove the integer column and rename the old column
    remove_column :tickets, :status
    rename_column :tickets, :status_old, :status
  end
end
