class UpdateIndexesOnTicketsForIdempotency < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :tickets, :assignee_id, name: "index_tickets_on_assignee_id", algorithm: :concurrently, if_not_exists: true
    add_index :tickets, :status, name: "index_tickets_on_status", algorithm: :concurrently, if_not_exists: true
    add_index :tickets, :urgency, name: "index_tickets_on_urgency", algorithm: :concurrently, if_not_exists: true
    add_index :tickets, :impact, name: "index_tickets_on_impact", algorithm: :concurrently, if_not_exists: true
    add_index :tickets, :priority, name: "index_tickets_on_priority", algorithm: :concurrently, if_not_exists: true
    add_index :tickets, :team_id, name: "index_tickets_on_team_id", algorithm: :concurrently, if_not_exists: true
  end
end