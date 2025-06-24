class TicketPolicy < ApplicationPolicy
  attr_reader :user, :ticket

  def initialize(user, ticket)
    @user = user
    @ticket = ticket
  end

  def index?
    user.system_admin? || user.domain_admin? || user.general_manager? || user.department_manager? || user.service_desk_agent?
  end

  def show?
    user.system_admin? || ticket.organization_id == user.organization_id
  end

  def create?
    can_create_ticket?
  end

  def update?
    return true if user.system_admin?

    if user.domain_admin? || user.general_manager? || user.department_manager?
      ticket.organization_id == user.organization_id
    else
      assigned_to_user_or_team?
    end
  end

  def destroy?
    user.system_admin? ||
      (user.domain_admin? && same_organization?) ||
      (user.general_manager? && same_organization?) ||
      (user.department_manager? && same_organization?)
  end

  def resolve?
    update? # same logic as update
  end

  def assign?
    user.system_admin? || user.domain_admin? || user.general_manager?
  end

  def change_urgency?
    assign?
  end

  class Scope < Scope
    def resolve
      if user.system_admin?
        scope.all
      elsif user.domain_admin? || user.general_manager? || user.department_manager? || user.service_desk_agent?
        scope.where(organization_id: user.organization_id)
      else
        scope.none
      end
    end
  end

  private

  def same_organization?
    ticket.organization_id == user.organization_id
  end

  def assigned_to_user_or_team?
    ticket.assignee_id == user.id || user.team_ids&.include?(ticket.team_id)
  end

  def can_create_ticket?
    user.role_call_center_agent? ||
      user.role_service_desk_agent? ||
      user.role_service_desk_tl? ||
      user.role_incident_manager? ||
      user.role_problem_manager? ||
      user.role_department_manager? ||
      user.role_general_manager? ||
      user.role_domain_admin? ||
      user.role_system_admin?
  end
end
