# frozen_string_literal: true
class Ticket < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :organization
  belongs_to :creator, class_name: "User", foreign_key: "creator_id"
  belongs_to :requester, class_name: "User", foreign_key: "requester_id"
  belongs_to :assignee, class_name: "User", foreign_key: "assignee_id", optional: true
  belongs_to :team, optional: true
  belongs_to :sla_policy, optional: true

  has_many :problems, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :create_tickets, class_name: "Ticket", foreign_key: "creator_id"
  has_many :requested_tickets, class_name: "Ticket", foreign_key: "requester_id"
  has_many :tickets, foreign_key: "user_id"

  # Enums
  enum status: { open: 0, assigned: 1, escalated: 2, closed: 3, suspended: 4, resolved: 5, pending: 6 }
  enum urgency: { Low: 0, Medium: 1, High: 2 }, _prefix: :urgency
  enum impact: { Low: 0, Medium: 1, High: 2 }, _prefix: :impact
  enum priority: { p4: 0, p3: 1, p2: 2, p1: 3 }

  # Validations
  validates :title, :description, :urgency, :impact, presence: true
  validates :user_id, presence: true

  # Scopes
  scope :for_user_in_organization, ->(user_id, organization_id) {
    where(creator_id: user_id, organization_id: organization_id)
  }
  scope :sla_breached, -> { where(sla_breached: true) }
  scope :pending_response, -> { where("response_due_at < ?", Time.current) }
  scope :pending_resolution, -> { where("resolution_due_at < ?", Time.current) }

  # Callbacks
  before_save :calculate_priority
  after_commit :update_sla_dates, on: [:create, :update]
  after_create :create_notifications

  # SLA Methods
  def calculate_sla_dates
    self.sla_policy ||= organization.sla_policies.find_by(priority: priority)
    return unless sla_policy

    calculator = SlaCalculator.new(self)
    self.response_due_at = calculator.response_due_date
    self.resolution_due_at = calculator.resolution_due_date
    self.sla_breached = calculator.breached?
  end

  private

  def calculate_priority
    self.priority = priority_matrix["#{urgency}_#{impact}"] || :p4
  end

  def priority_matrix
    {
      "High_High" => :p1,
      "High_Medium" => :p2,
      "High_Low" => :p3,
      "Medium_High" => :p2,
      "Medium_Medium" => :p3,
      "Medium_Low" => :p4,
      "Low_High" => :p3,
      "Low_Medium" => :p4,
      "Low_Low" => :p4
    }.with_indifferent_access
  end

  def update_sla_dates
    return if destroyed? || !sla_attributes_changed?
    
    calculate_sla_dates
    save! if changed?
  end

  def sla_attributes_changed?
    saved_change_to_urgency? || saved_change_to_impact? || saved_change_to_priority?
  end

  def create_notifications
    admin = organization.users.find_by(role: :admin)
    Notification.create!(
      user: admin,
      organization: organization,
      message: "New ticket created: #{title}"
    ) if admin

    return unless assignee
    
    Notification.create!(
      user: assignee,
      organization: organization,
      message: "You have been assigned to a new ticket: #{title}"
    )
  end
end