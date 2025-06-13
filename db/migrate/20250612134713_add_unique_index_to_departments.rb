# frozen_string_literal: true
class AddUniqueIndexToDepartments < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    # Remove duplicates before adding unique index
    duplicate_depts = Department.group(:organization_id, :name)
                                .having('COUNT(*) > 1')
                                .pluck(:organization_id, :name)
    
    duplicate_depts.each do |org_id, name|
      depts = Department.where(organization_id: org_id, name: name).order(:id)
      depts[1..-1].each do |dept|
        # Update dependent records to point to the first department
        User.where(department_id: dept.id).update_all(department_id: depts.first.id)
        Ticket.where(department_id: dept.id).update_all(department_id: depts.first.id)
        dept.destroy
      end
    end

    # Add composite unique index
    safety_assured do
      add_index :departments, [:organization_id, :name], unique: true, name: 'index_departments_on_org_id_and_name'
    end
  end

  def down
    remove_index :departments, name: 'index_departments_on_org_id_and_name'
  end
end