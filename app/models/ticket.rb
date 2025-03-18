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
  enum status: { open: 0, assigned: 1, escalated: 2, closed: 3, suspended: 4, resolved: 5, pending: 6 }, _default: :open
  enum urgency: { low: 0, medium: 1, high: 2 }, _prefix: :urgency
  enum impact: { low: 0, medium: 1, high: 2 }, _prefix: :impact
  enum priority: { p4: 0, p3: 1, p2: 2, p1: 3 }

  # Validations
  validates :title, :description, :urgency, :impact, presence: true
  validates :user_id, presence: true
  validates :ticket_number, presence: true, uniqueness: true
  validates :ticket_type, :reported_at, :category, :caller_name, :caller_surname, :caller_email, :caller_phone, :customer, :source, presence: true

  # Scopes
  scope :for_user_in_organization, ->(user_id, organization_id) { where(creator_id: user_id, organization_id: organization_id) }
  scope :sla_breached, -> { where(sla_breached: true) }
  scope :pending_response, -> { where("response_due_at < ?", Time.current).where.not(status: [:closed, :resolved]) }
  scope :pending_resolution, -> { where("resolution_due_at < ?", Time.current).where.not(status: [:closed, :resolved]) }

  # Callbacks
  before_save :set_calculated_priority
  after_commit :update_sla_dates, on: [:create, :update]
  after_create :create_notifications

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
    Rails.logger.debug "Calculating due date: start_time=#{start_time}, duration_minutes=#{duration_minutes}"
    return start_time + duration_minutes.minutes unless business_hours.any?

    remaining_minutes = duration_minutes
    current_time = start_time.dup
    max_days = 365

    max_days.times do |day_offset|
      Rails.logger.debug "Day offset: #{day_offset}, current_time: #{current_time}, remaining_minutes: #{remaining_minutes}"
      current_day = business_hours.find { |bh| bh.day_of_week == current_time.wday.to_s }
      
      if current_day && within_business_hours?(current_time, current_day)
        end_of_day = Time.zone.parse("#{current_time.to_date} #{current_day.end_time.strftime('%H:%M:%S')}")
        time_until_end = ((end_of_day - current_time) / 60).floor
        minutes_to_add = [remaining_minutes, time_until_end].min
        current_time += minutes_to_add.minutes
        remaining_minutes -= minutes_to_add
        Rails.logger.debug "Added #{minutes_to_add} minutes, new current_time: #{current_time}, remaining: #{remaining_minutes}"
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
        Rails.logger.debug "Moved to next business day: #{current_time}"
      end
    end

    if remaining_minutes > 0
      Rails.logger.warn "SLA calculation exceeded #{max_days} days for Ticket ##{id}, remaining: #{remaining_minutes} minutes"
      current_time += remaining_minutes.minutes
    end

    Rails.logger.debug "Due date calculated: #{current_time}"
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