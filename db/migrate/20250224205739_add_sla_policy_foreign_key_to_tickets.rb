# db/migrate/[timestamp]_add_sla_policy_foreign_key_to_tickets.rb
class AddSlaPolicyForeignKeyToTickets < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_foreign_key :tickets, :sla_policies, 
                    validate: false
                    
    validate_foreign_key :tickets, :sla_policies
  end
end