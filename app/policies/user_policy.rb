class UserPolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5
  attr_reader :current_user, :user

  def initialize(current_user, user)
    @current_user = current_user
    @user = user
  end

  def index?
    current_user.role_admin? || current_user.role_teamlead?
  end

  def show?
    current_user.role_admin? || current_user.role_teamlead? || current_user == user
  end

  def create?
    current_user.role_admin?
  end

  def update?
    current_user.role_admin? || (current_user.role_teamlead? && user.role_agent?)
  end

  def destroy?
    current_user.role_admin?
  end

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end
end
