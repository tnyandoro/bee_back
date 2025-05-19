class UserPolicy < ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    # System Admin: Full access
    # Domain Admin, General Manager, Department Manager: View users in their organization
    user.system_admin? || user.domain_admin? || user.general_manager? || user.department_manager?
  end

  def show?
    # System Admin: View any user
    # Domain Admin, General Manager: View users in their organization
    # Department Manager: View users in their department
    # Others: View themselves only
    user.system_admin? ||
      (user.domain_admin? && user.organization_id == record.organization_id) ||
      (user.general_manager? && user.organization_id == record.organization_id) ||
      (user.department_manager? && user.department_id == record.department_id) ||
      user == record
  end

  def create?
    # System Admin: Create any user
    # Domain Admin: Create users in their organization
    # Department Manager: Create users in their department
    # General Manager: Create users in their organization
    user.system_admin? ||
      (user.domain_admin? && record.organization_id == user.organization_id) ||
      (user.department_manager? && record.department_id == user.department_id) ||
      (user.general_manager? && record.organization_id == user.organization_id)
  end

  def update?
    # System Admin: Update any user
    # Domain Admin: Update users in their organization
    # Department Manager: Update users in their department
    # General Manager: Update users in their organization
    # Others: Update themselves
    user.system_admin? ||
      (user.domain_admin? && user.organization_id == record.organization_id) ||
      (user.department_manager? && user.department_id == record.department_id) ||
      (user.general_manager? && user.organization_id == record.organization_id) ||
      user == record
  end

  def destroy?
    # System Admin: Delete any user
    # Domain Admin: Delete users in their organization
    # Department Manager: Delete users in their department
    # General Manager: Delete users in their organization
    user.system_admin? ||
      (user.domain_admin? && user.organization_id == record.organization_id) ||
      (user.department_manager? && user.department_id == record.department_id) ||
      (user.general_manager? && user.organization_id == record.organization_id)
  end

  class Scope < Scope
    def resolve
      if user.system_admin?
        # System Admin: All users
        scope.all
      elsif user.domain_admin? || user.general_manager?
        # Domain Admin, General Manager: Users in their organization
        scope.where(organization_id: user.organization_id)
      elsif user.department_manager?
        # Department Manager: Users in their department
        scope.where(department_id: user.department_id)
      else
        # Others (e.g., service_desk_agent): Only themselves
        scope.where(id: user.id)
      end
    end
  end
end