# frozen_string_literal: true
class Problem < ApplicationRecord
  belongs_to :ticket
  belongs_to :creator, class_name: "User"
  belongs_to :user, optional: true # The user assigned to resolve the problem
  belongs_to :team, optional: true

  # Delegate organization to ticket
  delegate :organization, to: :ticket

  validates :description, presence: true
  validates :ticket, presence: true
  validates :creator, presence: true
end
