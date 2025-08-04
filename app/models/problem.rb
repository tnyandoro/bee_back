# frozen_string_literal: true
class Problem < ApplicationRecord
  belongs_to :ticket
  belongs_to :creator, class_name: "User"
  belongs_to :user, optional: true
  belongs_to :team, optional: true
  belongs_to :organization 
  belongs_to :related_incident, class_name: "Ticket", optional: true
  


  # delegate :organization, to: :ticket, allow_nil: true

  validates :description, presence: true
  validates :creator, presence: true
  validates :organization, presence: true
end