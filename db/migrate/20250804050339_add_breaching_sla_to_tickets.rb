class AddBreachingSlaToTickets < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    # Step 1: Add the column (can have a default)
    add_column :tickets, :breaching_sla, :boolean, default: false

    # Step 2: Add the index CONCURRENTLY (no downtime)
    add_index :tickets, :breaching_sla, algorithm: :concurrently
  end
end
