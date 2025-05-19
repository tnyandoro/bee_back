# app/models/sla_policy.rb
class SlaPolicy < ApplicationRecord
    belongs_to :organization
    has_many :tickets
  
    enum priority: Ticket.priorities
  
    validates :response_time, :resolution_time, numericality: { greater_than: 0 }
    validates :priority, presence: true, uniqueness: { scope: :organization_id }
  
    def business_hours
      organization.business_hours
    end
end
