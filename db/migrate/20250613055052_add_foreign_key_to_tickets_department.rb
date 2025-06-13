class AddForeignKeyToTicketsDepartment < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    safety_assured do
      if column_exists?(:tickets, :department_id) && !foreign_key_exists?(:tickets, :departments)
        add_foreign_key :tickets, :departments
      end
    end
  end
end
