# frozen_string_literal: true
class FixDuplicateDepartmentsByDeletingInsteadOfDestroying < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    duplicate_depts = Department.group(:organization_id, :name)
                                .having('COUNT(*) > 1')
                                .pluck(:organization_id, :name)

    duplicate_depts.each do |org_id, name|
      depts = Department.where(organization_id: org_id, name: name).order(:id)
      primary_dept = depts.first

      depts[1..].each do |dept|
        User.where(department_id: dept.id).update_all(department_id: primary_dept.id)
        Ticket.where(department_id: dept.id).update_all(department_id: primary_dept.id)
        dept.delete  # Use delete to skip callbacks
      end
    end
  end

  def down
    # No-op: This migration is not reversible
    say "This migration is not reversible because deleted departments cannot be recovered."
  end
end
