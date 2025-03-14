class UserPolicy < ApplicationPolicy
  attr_reader :current_user, :user

  def initialize(current_user, user)
    @current_user = current_user
    @user = user
  end

  # Rename `current_user` to `user` in methods if aligning with ApplicationPolicy
  def index?
    user.role_admin? || user.role_teamlead?
  end

  def show?
    user.role_admin? || user.role_teamlead? || user == user  # Adjust if current_user comparison is intentional
  end

  def create?
    user.role_admin?
  end

  def update?
    user.role_admin? || (user.role_teamlead? && record.role_agent?)
  end

  def destroy?
    user.role_admin?
  end

  class Scope < ApplicationPolicy::Scope
    # Define resolve if needed, e.g.:
    # def resolve
    #   if user.role_admin?
    #     scope.all
    #   else
    #     scope.where(team_id: user.team_id)
    #   end
    # end
  end
end