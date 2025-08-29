class SlaPolicy < ApplicationRecord
  belongs_to :organization
  has_many :tickets
  
  # Match the priority enum values from your existing tickets
  enum priority: { low: 0, medium: 1, high: 2, critical: 3 }
  
  validates :response_time, :resolution_time, numericality: { greater_than: 0 }
  validates :priority, presence: true, uniqueness: { scope: :organization_id }
  
  def business_hours
    organization.business_hours
  end
end