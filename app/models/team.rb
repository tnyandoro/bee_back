class Team < ApplicationRecord
  belongs_to :organization
  has_many :users
  has_many :tickets

  validates :name, presence: true
  validates :organization, presence: true
end