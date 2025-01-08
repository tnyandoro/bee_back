class Ticket < ApplicationRecord
  # Associations
  belongs_to :creator, class_name: "User", foreign_key: "user_id" # The user who created the ticket
  belongs_to :assignee, class_name: "User", optional: true # The user assigned to the ticket
  belongs_to :team, optional: true
  belongs_to :requester, class_name: "User" # The user who requested the ticket
  belongs_to :organization

  # Validations
  validates :title, :description, :ticket_type, :status, :priority, :impact, :requester, :organization, :creator, presence: true
  validates :ticket_number, uniqueness: true
  validates :team_id, :reported_at, :category, :caller_name, :caller_surname, :caller_email, :caller_phone, :customer, :source, presence: true

  # Enums
  enum status: { open: "open", pending: "pending", resolved: "resolved", closed: "closed" }
  enum ticket_type: { incident: "Incident", service_request: "Service Request", problem: "Problem", change_request: "Change Request", task: "Task" }
  enum urgency: { urgent_high: "High", urgent_medium: "Medium", urgent_low: "Low" }
  enum priority: { critical: 1, high: 2, medium: 3, low: 4 }
  enum impact: { impact_high: "High", impact_medium: "Medium", impact_low: "Low" }

  # Callbacks
  before_validation :generate_ticket_number, on: :create

  # Ensure enum attributes are treated as strings
  attribute :status, :string
  attribute :ticket_type, :string
  attribute :urgency, :string
  attribute :priority, :string
  attribute :impact, :string

  private

  # Generate a unique ticket number with the subdomain as the first part
  def generate_ticket_number
    self.ticket_number ||= "#{organization.subdomain}-#{SecureRandom.alphanumeric(6).upcase}"
  end
end
