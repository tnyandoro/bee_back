class Problem < ApplicationRecord
  belongs_to :ticket
  belongs_to :organization
  belongs_to :team
  belongs_to :creator, class_name: "User"
  has_many :tickets, dependent: :nullify

  validates :description, presence: true
  validates :organization, presence: true
  validates :team, presence: true
  validates :creator, presence: true
end