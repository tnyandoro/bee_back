class AddSomeFieldToTickets < ActiveRecord::Migration[7.1]
  def change
    add_column :tickets, :some_field, :string
  end
end
