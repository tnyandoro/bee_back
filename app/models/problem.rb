# frozen_string_literal: true
class Problem < ApplicationRecord
  belongs_to :ticket
  belongs_to :user, optional: true

  # Delegate organization to ticket
  delegate :organization, to: :ticket

  validates :description, presence: true
  belongs_to :organization
  belongs_to :team
  belongs_to :creator, class_name: "User"
  has_many :tickets, dependent: :nullify

  validates :description, presence: true
  validates :organization, presence: true
  validates :team, presence: true
  validates :creator, presence: true
end