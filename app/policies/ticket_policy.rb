# app/policies/ticket_policy.rb
class TicketPolicy < ApplicationPolicy
  attr_reader :user, :ticket

  def initialize(user, ticket)
    @user = user
    @ticket = ticket
  end

  def index?
    # Service Desk Agent: All tickets in their org
    # Admins/Managers: Full access within their scope
    user.service_desk_agent? || user.can_view_all_tickets?
  end

  def show?
    return true if user.system_admin?

    # Domain Admin, General Manager, Department Manager: Same org
    # Service Desk Agent: Same org
    ticket.organization_id == user.organization_id
  end

  def create?
    user.can_create_tickets?("Incident")
  end

  def update?
    return true if user.system_admin?

    # Admins and managers can edit tickets in same organization
    if user.domain_admin? || user.general_manager? || user.department_manager?
      ticket.organization_id == user.organization_id
    else
      # Regular users (like service desk agents) can only edit tickets assigned to them or their team
      assigned_to_user_or_team?
    end
  end

  def destroy?
    user.system_admin? ||
      (user.domain_admin? && ticket.organization_id == user.organization_id) ||
      (user.general_manager? && ticket.organization_id == user.organization_id) ||
      (user.department_manager? && ticket.organization_id == user.organization_id)
  end

  def resolve?
    return true if user.system_admin?

    if user.domain_admin? || user.general_manager? || user.department_manager?
      ticket.organization_id == user.organization_id
    else
      assigned_to_user_or_team?
    end
  end

  def assign?
    user.can_reassign_tickets?
  end

  def change_urgency?
    user.can_change_urgency?
  end

  class Scope < Scope
    def resolve
      if user.system_admin?
        # System Admin sees all tickets
        scope.all
      elsif user.service_desk_agent? || user.can_view_all_tickets?
        # Service Desk Agent and others with view-all access see all tickets in their org
        scope.where(organization_id: user.organization_id)
      elsif user.domain_admin? || user.general_manager? || user.department_manager?
        # Admin roles also see all tickets in their org
        scope.where(organization_id: user.organization_id)
      else
        # Others (e.g., level support) may only see assigned tickets — handled separately
        scope.none
      end
    end
  end

  private

  def assigned_to_user_or_team?
    ticket.assignee_id == user.id || ticket.team_id == user.team_id
  end
end