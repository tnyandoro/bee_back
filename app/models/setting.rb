class Setting < ApplicationRecord
  belongs_to :organization
  validates :key, presence: true, uniqueness: { scope: :organization_id }
  serialize :value, JSON
end
