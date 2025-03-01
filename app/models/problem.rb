# frozen_string_literal: true
class Problem < ApplicationRecord
  belongs_to :ticket
  belongs_to :creator, class_name: "User"
  belongs_to :user, optional: true # The user assigned to resolve the problem
  belongs_to :team, optional: true
  belongs_to :organization # Explicitly add this for clarity in multi-tenant setup

  delegate :organization, to: :ticket, allow_nil: true # Keep as fallback but prefer explicit assignment

  validates :description, presence: true
  validates :creator, presence: true
  validates :organization, presence: true # Enforce organization context
end