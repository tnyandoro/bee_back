class TicketPolicy < ApplicationPolicy
  attr_reader :user, :ticket

  def initialize(user, ticket)
    @user = user
    @ticket = ticket
  end

  def index?
    # Service Desk Agent: View all tickets in their organization
    # Admins/Managers: Full access within their scope
    user.service_desk_agent? || user.system_admin? || user.domain_admin? ||
    user.general_manager? || user.department_manager?
  end

  def show?
    # Service Desk Agent: View any ticket in their organization
    # Admins/Managers: Full access within their scope
    (user.service_desk_agent? && ticket.organization_id == user.organization_id) ||
    user.system_admin? ||
    (user.domain_admin? && ticket.organization_id == user.organization_id) ||
    (user.general_manager? && ticket.organization_id == user.organization_id) ||
    (user.department_manager? && ticket.organization_id == user.organization_id)
  end

  def create?
    # Service Desk Agent: Can create tickets
    user.service_desk_agent? || user.system_admin? || user.domain_admin? ||
    user.general_manager? || user.department_manager?
  end

  def update?
    # Service Desk Agent: Update only tickets assigned to them or their team
    # Admins/Managers: Update within their scope
    (user.service_desk_agent? && assigned_to_user_or_team?) ||
    user.system_admin? ||
    (user.domain_admin? && ticket.organization_id == user.organization_id) ||
    (user.general_manager? && ticket.organization_id == user.organization_id) ||
    (user.department_manager? && ticket.organization_id == user.organization_id)
  end

  def destroy?
    # Service Desk Agent: Cannot delete tickets
    # Admins/Managers: Can delete within their scope
    user.system_admin? ||
    (user.domain_admin? && ticket.organization_id == user.organization_id) ||
    (user.general_manager? && ticket.organization_id == user.organization_id) ||
    (user.department_manager? && ticket.organization_id == user.organization_id)
  end

  def resolve?
    # Service Desk Agent: Resolve only tickets assigned to them or their team
    # Admins/Managers: Resolve within their scope
    (user.service_desk_agent? && assigned_to_user_or_team?) ||
    user.system_admin? ||
    (user.domain_admin? && ticket.organization_id == user.organization_id) ||
    (user.general_manager? && ticket.organization_id == user.organization_id) ||
    (user.department_manager? && ticket.organization_id == user.organization_id)
  end

  class Scope < Scope
    def resolve
      if user.service_desk_agent?
        # Service Desk Agent: All tickets in their organization
        scope.where(organization_id: user.organization_id)
      elsif user.system_admin?
        # System Admin: All tickets
        scope.all
      elsif user.domain_admin? || user.general_manager? || user.department_manager?
        # Admins/Managers: Tickets in their organization
        scope.where(organization_id: user.organization_id)
      else
        scope.none
      end
    end
  end

  private

  def assigned_to_user_or_team?
    ticket.assigned_to_id == user.id || ticket.team_id == user.team_id
  end
end