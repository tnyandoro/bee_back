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
  enum urgency: { low: 0, medium: 1, high: 2 }, _prefix: :urgency
  enum impact: { low: 0, medium: 1, high: 2 }, _prefix: :impact
  enum priority: { p4: 0, p3: 1, p2: 2, p1: 3 }

  # Validations
  validates :title, :description, :urgency, :impact, presence: true
  validates :user_id, presence: true

  # Scopes
  scope :for_user_in_organization, ->(user_id, organization_id) {
    where(creator_id: user_id, organization_id: organization_id)
  }
  scope :sla_breached, -> { where(sla_breached: true) }
  scope :pending_response, -> { where("response_due_at < ?", Time.current).where.not(status: [:closed, :resolved]) }
  scope :pending_resolution, -> { where("resolution_due_at < ?", Time.current).where.not(status: [:closed, :resolved]) }

  # Callbacks
  before_save :set_calculated_priority
  after_commit :update_sla_dates, on: [:create, :update]

  # SLA Methods
  def calculate_sla_dates
    self.sla_policy ||= organization.sla_policies.find_by(priority: calculated_priority || priority)
    return unless sla_policy

    business_hours = organization.business_hours
    reported_time = reported_at || Time.current

    self.response_due_at = calculate_due_date(reported_time, sla_policy.response_time, business_hours)
    self.resolution_due_at = calculate_due_date(reported_time, sla_policy.resolution_time, business_hours)
    self.sla_breached = sla_breached?
  end

  def sla_breached?
    return false if status.in?(['closed', 'resolved'])
    (response_due_at && Time.current > response_due_at) || 
    (resolution_due_at && Time.current > resolution_due_at)
  end

  private

  def set_calculated_priority
    self.calculated_priority = priority_matrix["#{urgency}_#{impact}"] || :p4
    self.priority = calculated_priority unless priority_changed? # Only set priority if not explicitly changed
  end

  def priority_matrix
    {
      "high_high" => :p1,
      "high_medium" => :p2,
      "high_low" => :p3,
      "medium_high" => :p2,
      "medium_medium" => :p3,
      "medium_low" => :p4,
      "low_high" => :p3,
      "low_medium" => :p4,
      "low_low" => :p4
    }.with_indifferent_access
  end

  def update_sla_dates
    return if destroyed? || !sla_attributes_changed?

    calculate_sla_dates
    update_columns(
      response_due_at: response_due_at,
      resolution_due_at: resolution_due_at,
      sla_breached: sla_breached
    ) if changed?
  end

  def sla_attributes_changed?
    saved_change_to_urgency? || saved_change_to_impact? || saved_change_to_priority? || 
    saved_change_to_sla_policy_id? || reported_at_changed?
  end

  def calculate_due_date(start_time, duration_minutes, business_hours)
    return start_time + duration_minutes.minutes unless business_hours.any? # Fallback if no business hours

    remaining_minutes = duration_minutes
    current_time = start_time.dup

    loop do
      break if remaining_minutes <= 0
      current_day = business_hours.find { |bh| bh.day_of_week == current_time.wday.to_s }
      next_day_start = current_time.end_of_day + 1.second

      if current_day && within_business_hours?(current_time, current_day)
        time_until_end = ((current_day.end_time - current_time) / 60).floor
        minutes_to_add = [remaining_minutes, time_until_end].min
        current_time += minutes_to_add.minutes
        remaining_minutes -= minutes_to_add
      else
        current_time = next_day_start
        current_time += 1.minute until business_hours.any? { |bh| bh.day_of_week == current_time.wday.to_s }
      end
    end

    current_time
  end

  def within_business_hours?(time, business_hour)
    time_of_day = time.seconds_since_midnight
    business_hour.working_hours.cover?(time_of_day)
  end

  def create_notifications
    admin = organization.users.find_by(role: :admin)
    Notification.create!(
      user: admin,
      organization: organization,
      message: "New ticket created: #{title}",
      read: false
    ) if admin

    return unless assignee

    Notification.create!(
      user: assignee,
      organization: organization,
      message: "You have been assigned to a new ticket: #{title}",
      read: false
    )
  end
end