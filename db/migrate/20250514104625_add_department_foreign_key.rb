class AddDepartmentForeignKey < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :users, :department_id, algorithm: :concurrently
    add_foreign_key :users, :departments, column: :department_id, validate: false
    validate_foreign_key :users, :departments
  end
end
