class AddResolutionFieldsToTickets < ActiveRecord::Migration[7.1]
  def change
    add_column :tickets, :reason, :string
    add_column :tickets, :resolution_method, :string
    add_column :tickets, :cause_code, :string
    add_column :tickets, :resolution_details, :text
    add_column :tickets, :end_customer, :string
    add_column :tickets, :support_center, :string
    add_column :tickets, :total_kilometer, :string
  end
end
