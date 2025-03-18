class Team < ApplicationRecord
  belongs_to :organization
  has_many :users, dependent: :nullify
  has_many :tickets, dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: :organization_id }
  validates :organization, presence: true
end 