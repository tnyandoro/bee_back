# frozen_string_literal: true
# This migration adds indexes to the tickets table to improve query performance.
# It uses the `algorithm: :concurrently` option to avoid locking the table during index creation.

class AddIndexesToTickets < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :tickets, :assignee_id, name: "index_tickets_on_assignee_id", algorithm: :concurrently
    add_index :tickets, :status, name: "index_tickets_on_status", algorithm: :concurrently
    add_index :tickets, :urgency, name: "index_tickets_on_urgency", algorithm: :concurrently
    add_index :tickets, :impact, name: "index_tickets_on_impact", algorithm: :concurrently
    add_index :tickets, :priority, name: "index_tickets_on_priority", algorithm: :concurrently
    add_index :tickets, :team_id, name: "index_tickets_on_team_id", algorithm: :concurrently
  end
end