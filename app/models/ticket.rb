# frozen_string_literal: true
class InvalidPriorityError < StandardError; end
class SlaCalculationError < StandardError; end

class Ticket < ApplicationRecord
  has_paper_trail unless Ticket.included_modules.include?(PaperTrail::Model::InstanceMethods)

  self.ignored_columns += ["user_id"]

  after_create :send_assignment_email, if: -> { assignee.present? }

  belongs_to :organization
  belongs_to :creator, class_name: "User"
  belongs_to :requester, class_name: "User"
  belongs_to :assignee, class_name: "User", optional: true
  belongs_to :team, optional: true
  belongs_to :sla_policy, optional: true
  
  has_one_attached :attachment

  has_many_attached :files
  has_many :problems, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :created_tickets, class_name: "Ticket", foreign_key: "creator_id", dependent: :nullify
  has_many :requested_tickets, class_name: "Ticket", foreign_key: "requester_id", dependent: :nullify
  has_many :notifications, as: :notifiable, dependent: :destroy

  enum status: { open: 0, assigned: 1, escalated: 2, closed: 3, suspended: 4, resolved: 5, pending: 6 }, _default: :open
  enum urgency: { low: 0, medium: 1, high: 2 }, _prefix: :urgency
  enum impact: { low: 0, medium: 1, high: 2 }, _prefix: :impact
  enum priority: { p4: 0, p3: 1, p2: 2, p1: 3 }, _prefix: true

  validates :title, :description, :urgency, :impact, presence: true
  validates :creator, :requester, presence: true
  validates :ticket_number, presence: true, uniqueness: { message: "Ticket number is already taken"}
  validates :ticket_type, :reported_at, :category, :caller_name, :caller_surname,
            :caller_email, :caller_phone, :customer, :source, presence: true
  validates :ticket_type, inclusion: { in: %w[Incident Request Problem], message: "must be one of: Incident, Request, Problem" }
  validates :category, inclusion: { in: %w[Query Complaint Compliment Other], message: "must be one of: Query, Complaint, Compliment, Other" } # updated categories
  validates :status, inclusion: { in: statuses.keys }
  validate :assignee_belongs_to_team, if: -> { assignee_id.present? && team_id.present? }
  validate :attachment
  validate :files_format

  scope :for_user_in_organization, ->(user_id, organization_id) do
    where(creator_id: user_id, organization_id: organization_id)
  end
  scope :sla_breached, -> { where(sla_breached: true) }
  scope :response_overdue, -> { where('response_due_at < ?', Time.current) }
  scope :resolution_overdue, -> { where('resolution_due_at < ?', Time.current) }
  scope :pending_response, -> { where("response_due_at < ?", Time.current).where.not(status: [:closed, :resolved]) }
  scope :pending_resolution, -> { where("resolution_due_at < ?", Time.current).where.not(status: [:closed, :resolved]) }
  scope :search_by_title_or_description, ->(query) do
    where("title ILIKE ? OR description ILIKE ?", "%#{query}%", "%#{query}%")
  end

  before_validation :generate_ticket_number, on: :create
  before_validation :normalize_priority
  before_save :set_calculated_priority
  after_create :calculate_sla_on_create
  after_update :recalculate_sla_if_needed

  def create?
    requester.can_create_ticket?
  end

  def resolve(resolved_by:)
    raise ArgumentError, "resolved_by must be a User" unless resolved_by.is_a?(User)
    update!(status: :resolved, assignee: resolved_by, resolved_at: Time.current)
    create_resolution_notifications(resolved_by)
  end

  def reopen(reopened_by:)
    raise ArgumentError, "reopened_by must be a User" unless reopened_by.is_a?(User)
    update!(status: :open, assignee: nil, resolved_at: nil)
    create_reopen_notification(reopened_by)
  end

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

  def calculate_sla!
    return unless organization.has_sla_configuration?
    
    # Find SLA policy based on calculated priority, then priority, then fallback to p4
    policy = organization.sla_policies.find_by(priority: priority_for_sla_lookup) ||
             organization.sla_policies.find_by(priority: 'p4')
    
    return unless policy
    
    self.sla_policy = policy
    SlaCalculator.new(self).calculate
    save! if changed?
  end

  def response_overdue?
    response_due_at && Time.current > response_due_at && !%w[closed resolved].include?(status)
  end

  def resolution_overdue?
    resolution_due_at && Time.current > resolution_due_at && !%w[closed resolved].include?(status)
  end

  def sla_breached?
    return false if %w[closed resolved].include?(status)
    response_overdue? || resolution_overdue?
  end

  def update_sla_breach_status!
    was_breached = sla_breached
    is_breached = sla_breached?
    
    if was_breached != is_breached
      update_columns(sla_breached: is_breached, breaching_sla: is_breached)
      if is_breached
        Rails.logger.info "Ticket #{ticket_number} SLA breached"
        # Could trigger notifications here
      end
    end
  end

  private

  def priority_for_sla_lookup
    # Map priority enum to what SLA policies expect
    case priority
    when 'p1' then 'critical'
    when 'p2' then 'high'
    when 'p3' then 'medium'
    when 'p4' then 'low'
    else 'low'
    end
  end

  def calculate_sla_on_create
    return unless persisted?
    
    begin
      calculate_sla!
    rescue => e
      Rails.logger.error "SLA calculation failed for ticket #{ticket_number}: #{e.message}"
      # Don't fail ticket creation if SLA calculation fails
    end
  end

  def recalculate_sla_if_needed
    return unless persisted?
    return unless priority_changed? || urgency_changed? || impact_changed?
    
    begin
      calculate_sla!
    rescue => e
      Rails.logger.error "SLA recalculation failed for ticket #{ticket_number}: #{e.message}"
    end
  end

  def generate_ticket_number
    return if ticket_number.present?

    prefix = prefix_for_type(ticket_type)
    sequence_name = sequence_for_type(ticket_type, organization_id)

    begin
      sequence_value = ActiveRecord::Base.connection.select_value(
        "SELECT nextval(#{ActiveRecord::Base.connection.quote(sequence_name)})"
      )
      self.ticket_number = "#{prefix}#{Time.current.strftime('%Y%m')}-#{sequence_value.to_s.rjust(5, '0')}"
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.error "Failed to generate ticket number for organization_id #{organization_id}: #{e.message}"
      raise ActiveRecord::RecordInvalid, self, "Sequence #{sequence_name} does not exist."
    end
  end

  def prefix_for_type(type)
    {
      "Incident" => "INC",
      "Request" => "REQ",
      "Problem" => "PRB"
    }.fetch(type, "TKT")
  end

  def sequence_for_type(type, org_id)
    base = {
      "Incident" => "tickets_inc",
      "Request" => "tickets_req",
      "Problem" => "tickets_prb"
    }.fetch(type, "tickets_tkt")

    "#{base}_organization_#{org_id}_seq"
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

  def files_format
    return unless files.attached?
    files.each do |file|
      unless file.content_type == "application/pdf"
        errors.add(:files, "must all be PDF files")
        break
      end
    end
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

  def send_assignment_email
    SendTicketAssignmentEmailsJob.perform_later(id, team_id, assignee_id)
  end

  def send_ticket_created_email
    TicketMailer.ticket_created(self).deliver_later
  end

  def attachment_format
    return unless attachment.attached?
    unless attachment.content_type == "application/pdf"
      errors.add(:attachment, "must be a PDF file")
    end
  end 
end