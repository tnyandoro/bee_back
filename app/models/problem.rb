# frozen_string_literal: true
class Problem < ApplicationRecord
  belongs_to :ticket
  belongs_to :user, optional: true

  # Delegate organization to ticket
  delegate :organization, to: :ticket

  validates :description, presence: true
end