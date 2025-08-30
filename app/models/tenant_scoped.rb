module TenantScoped
  extend ActiveSupport::Concern
  
  included do
    belongs_to :tenant
    default_scope -> { where(tenant: Current.tenant) if Current.tenant }
  end
end