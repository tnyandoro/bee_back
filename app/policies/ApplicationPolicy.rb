# app/policies/application_policy.rb
class ApplicationPolicy
    attr_reader :user, :record
  
    def initialize(user, record)
      @user = user
      @record = record
    end
  
    def index?
      false  # Default: deny access
    end
  
    def show?
      false
    end
  
    def create?
      false
    end
  
    def new?
      create?
    end
  
    def update?
      false
    end
  
    def edit?
      update?
    end
  
    def destroy?
      false
    end
  
    def scope
      Pundit.policy_scope!(user, record.class)
    end
  
    class Scope
      def initialize(user, scope)
        @user = user
        @scope = scope
      end
  
      def resolve
        scope.all  # Default: return all records; override in specific policies
      end
  
      private
  
      attr_reader :user, :scope
    end
end