# db/migrate/[timestamp]_add_sla_policy_to_tickets.rb
class AddSlaPolicyToTickets < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_reference :tickets, :sla_policy, 
                  null: false, 
                  index: { algorithm: :concurrently }
  end
end