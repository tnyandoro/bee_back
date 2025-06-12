# frozen_string_literal: true
class InvalidPriorityError < StandardError; end
class SlaCalculationError < StandardError; end

class Ticket < ApplicationRecord
  # Optional: For audit trail
  has_paper_trail class_name: 'TicketVersion'

  self.ignored_columns += ["user_id"]

  # Associations
  belongs_to :organization
  belongs_to :creator, class_name: "User"
  belongs_to :requester, class_name: "User"
  belongs_to :assignee, class_name: "User", optional: true
  belongs_to :team, optional: true
  belongs_to :sla_policy, optional: true

  has_many :problems, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :created_tickets, class_name: "Ticket", foreign_key: "creator_id", dependent: :nullify
  has_many :requested_tickets, class_name: "Ticket", foreign_key: "requester_id", dependent: :nullify
  has_many :notifications, as: :notifiable, dependent: :destroy

  # Enums
  enum status: { open: 0, assigned: 1, escalated: 2, closed: 3, suspended: 4, resolved: 5, pending: 6 }, _default: :open
  enum urgency: { low: 0, medium: 1, high: 2 }, _prefix: :urgency
  enum impact: { low: 0, medium: 1, high: 2 }, _prefix: :impact
  enum priority: { p4: 0, p3: 1, p2: 2, p1: 3 }, _prefix: true

  # Validations
  validates :title, :description, :urgency, :impact, presence: true
  validates :creator, :requester, presence: true
  validates :ticket_number, presence: true, uniqueness: true
  validates :ticket_type, :reported_at, :category, :caller_name, :caller_surname,
            :caller_email, :caller_phone, :customer, :source, presence: true
  validates :ticket_type, inclusion: { in: %w[Incident Request Problem], message: "must be one of: Incident, Request, Problem" }
  validates :category, inclusion: { in: %w[Technical Billing Support Hardware Software Other], message: "must be one of: Technical, Billing, Support, Hardware, Software, Other" }
  validates :status, inclusion: { in: statuses.keys }
  validate :assignee_belongs_to_team, if: -> { assignee_id.present? && team_id.present? }

  # Scopes
  scope :for_user_in_organization, ->(user_id, organization_id) do
    where(creator_id: user_id, organization_id: organization_id)
  end
  scope :sla_breached, -> { where(sla_breached: true) }
  scope :pending_response, -> { where("response_due_at < ?", Time.current).where.not(status: [:closed, :resolved]) }
  scope :pending_resolution, -> { where("resolution_due_at < ?", Time.current).where.not(status: [:closed, :resolved]) }
  scope :search_by_title_or_description, ->(query) do
    where("title ILIKE ? OR description ILIKE ?", "%#{query}%", "%#{query}%")
  end

  # Callbacks
  before_validation :generate_ticket_number, on: :create
  before_validation :normalize_priority
  before_save :set_calculated_priority
  after_commit :update_sla_dates, on: [:create, :update]

  # Public Methods
  def resolve(resolved_by:)
    raise ArgumentError, "resolved_by must be a User" unless resolved_by.is_a?(User)
    update!(status: :resolved, assignee: resolved_by)
    create_resolution_notifications(resolved_by)
  end

  def reopen(reopened_by:)
    raise ArgumentError, "reopened_by must be a User" unless reopened_by.is_a?(User)
    update!(status: :open, assignee: nil)
    create_reopen_notification(reopened_by)
  end

  # Priority conversion method
  def priority=(value)
    case value.to_s
    when '0', 'p4' then super(:p4)
    when '1', 'p3' then super(:p3)
    when '2', 'p2' then super(:p2)
    when '3', 'p1' then super(:p1)
    else
      super(value)
    end
  end

  # SLA Methods
  def calculate_sla_dates
    self.sla_policy ||= organization.sla_policies.find_by(priority: calculated_priority || priority) ||
                        organization.sla_policies.find_by(priority: :p4)
    unless sla_policy && organization.business_hours.any?
      Rails.logger.warn "Skipping SLA calculation for Ticket ##{id}: No SLA policy or business hours found"
      return
    end

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

  def generate_ticket_number
    return if ticket_number.present?

    prefix = case ticket_type
             when "Incident" then "INC"
             when "Request" then "REQ"
             when "Problem" then "PRB"
             else "TKT"
             end

    sequence = Ticket.where(organization_id: organization_id).count + 1
    self.ticket_number = "#{prefix}#{Time.current.strftime('%Y%m')}-#{sequence.to_s.rjust(5, '0')}"
  end

  def assignee_belongs_to_team
    return unless assignee && team
    unless team.users.include?(assignee)
      errors.add(:assignee, "must belong to the selected team")
    end
  end

  def normalize_priority
    return unless priority_changed?
    self.priority = case priority_before_type_cast.to_s
                    when '0' then :p4
                    when '1' then :p3
                    when '2' then :p2
                    when '3' then :p1
                    else priority
                    end
  end

  def validate_priority_value
    return unless priority_changed?
    unless Ticket.priorities.keys.include?(priority.to_s)
      errors.add(:priority, "must be one of: #{Ticket.priorities.keys.join(', ')} or 0-3")
    end
  end

  def set_calculated_priority
    calculated = priority_matrix["#{urgency}_#{impact}"] || :p4
    self.calculated_priority = self.class.priorities[calculated]
    self.priority = calculated_priority unless priority_changed?
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
    return if destroyed?
    begin
      calculate_sla_dates
      update_columns(
        response_due_at: response_due_at,
        resolution_due_at: resolution_due_at,
        sla_breached: sla_breached
      )
    rescue => e
      Rails.logger.error "Failed to update SLA dates for Ticket ##{id}: #{e.message}"
    end
  end

  def sla_attributes_changed?
    saved_change_to_urgency? || saved_change_to_impact? || saved_change_to_priority? ||
    saved_change_to_sla_policy_id? || reported_at_changed?
  end

  def calculate_due_date(start_time, duration_minutes, business_hours)
    return start_time + duration_minutes.minutes unless business_hours.any?
    remaining_minutes = duration_minutes
    current_time = start_time.dup
    max_days = 365
    max_days.times do |day_offset|
      current_day = business_hours.find { |bh| bh.day_of_week == current_time.wday.to_s }
      if current_day && within_business_hours?(current_time, current_day)
        end_of_day = Time.zone.parse("#{current_time.to_date} #{current_day.end_time.strftime('%H:%M:%S')}")
        time_until_end = ((end_of_day - current_time) / 60).floor
        minutes_to_add = [remaining_minutes, time_until_end].min
        current_time += minutes_to_add.minutes
        remaining_minutes -= minutes_to_add
        break if remaining_minutes <= 0
      else
        next_day = current_time + 1.day
        next_day_start = Time.zone.parse("#{next_day.to_date} 00:00:00")
        next_business_day = nil
        7.times do |i|
          check_day = next_day_start + i.days
          if business_hours.any? { |bh| bh.day_of_week == check_day.wday.to_s }
            next_business_day = check_day
            break
          end
        end
        unless next_business_day
          Rails.logger.warn "No business hours found within a week from #{next_day_start} for Ticket ##{id}"
          return current_time + remaining_minutes.minutes
        end
        start_of_next_day = business_hours.find { |bh| bh.day_of_week == next_business_day.wday.to_s }.start_time
        current_time = Time.zone.parse("#{next_business_day.to_date} #{start_of_next_day.strftime('%H:%M:%S')}")
      end
    end
    if remaining_minutes > 0
      Rails.logger.warn "SLA calculation exceeded #{max_days} days for Ticket ##{id}, remaining: #{remaining_minutes} minutes"
      current_time += remaining_minutes.minutes
    end
    current_time
  end

  def within_business_hours?(time, business_hour)
    time_of_day = time.seconds_since_midnight
    business_hour.working_hours.cover?(time_of_day)
  end

  def create_resolution_notifications(resolved_by)
    begin
      Notification.create!(
        user: requester,
        organization: organization,
        message: "Ticket resolved: #{title} (#{ticket_number})",
        read: false,
        notifiable: self
      )

      admin = organization.users.find_by(role: :system_admin)
      if admin
        Notification.create!(
          user: admin,
          organization: organization,
          message: "Ticket resolved by #{resolved_by.name}: #{title} (#{ticket_number})",
          read: false,
          notifiable: self
        )
      end
    rescue => e
      Rails.logger.error "Failed to create resolution notifications for Ticket ##{id}: #{e.message}"
    end
  end

  def create_reopen_notification(user)
    Notification.create!(
      user: requester,
      organization: organization,
      message: "Ticket reopened: #{title} (#{ticket_number})",
      read: false,
      notifiable: self
    )
  end
end