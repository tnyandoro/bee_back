class UserPolicy < ApplicationPolicy
  # Inherits user/record from ApplicationPolicy
  # user = current_user
  # record = target user being authorized

  def index?
    # Allow admins/super_users and team_leads
    user.admin? || user.role_team_lead?
  end

  def show?
    # Allow admins, team_leads, or users viewing themselves
    user.admin? || user.role_team_lead? || user == record
  end

  def create?
    # Only allow admins/super_users
    user.admin?
  end

  def update?
    # Admins can update anyone, team_leads can only update agents
    user.admin? || (user.role_team_lead? && record.role_agent?)
  end

  def destroy?
    # Only allow admins/super_users
    user.admin?
  end

  class Scope < Scope
    def resolve
      if user.admin?
        # Admins see all users in the organization
        scope.where(organization: user.organization)
      elsif user.role_team_lead?
        # Team leads see users in their team
        scope.where(team: user.team)
      else
        # Regular users only see themselves
        scope.where(id: user.id)
      end
    end
  end
end
