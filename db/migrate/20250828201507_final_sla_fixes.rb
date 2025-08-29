class FinalSlaFixes < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!
  
  def change
    # Add description field to sla_policies if it doesn't exist
    unless column_exists?(:sla_policies, :description)
      add_column :sla_policies, :description, :text
    end

    # Add active field to business_hours if it doesn't exist
    unless column_exists?(:business_hours, :active)
      add_column :business_hours, :active, :boolean, default: true, null: false
    end

    # Add unique constraint on sla_policies [organization_id, priority] if it doesn't exist
    unless index_exists?(:sla_policies, [:organization_id, :priority], unique: true)
      add_index :sla_policies, [:organization_id, :priority], 
                unique: true, 
                algorithm: :concurrently,
                name: 'index_sla_policies_on_org_id_and_priority'
    end

    # Add performance indexes for tickets SLA fields
    unless index_exists?(:tickets, :response_due_at)
      add_index :tickets, :response_due_at, algorithm: :concurrently
    end

    unless index_exists?(:tickets, :resolution_due_at)
      add_index :tickets, :resolution_due_at, algorithm: :concurrently
    end

    unless index_exists?(:tickets, :sla_breached)
      add_index :tickets, :sla_breached, algorithm: :concurrently
    end

    # Add composite index for common SLA queries
    unless index_exists?(:tickets, [:organization_id, :sla_breached])
      add_index :tickets, [:organization_id, :sla_breached], 
                algorithm: :concurrently,
                name: 'index_tickets_on_org_id_and_sla_breached'
    end
  end
end