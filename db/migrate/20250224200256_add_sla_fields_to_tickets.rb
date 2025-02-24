# db/migrate/[timestamp]_add_sla_fields_to_tickets.rb
class AddSlaFieldsToTickets < ActiveRecord::Migration[7.1]
  def change
    add_column :tickets, :response_due_at, :datetime
    add_column :tickets, :resolution_due_at, :datetime
    add_column :tickets, :escalation_level, :integer, default: 0
    add_column :tickets, :sla_breached, :boolean, default: false
  end
end