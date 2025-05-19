class User < ApplicationRecord
  # Authentication
  has_secure_password
  has_secure_token :auth_token
  has_one_attached :avatar

  # Add an accessor to skip auth_token generation
  attr_accessor :skip_auth_token

  # Associations
  belongs_to :organization
  belongs_to :team, optional: true

  has_many :tickets, dependent: :destroy
  has_many :assigned_tickets, class_name: "Ticket", foreign_key: "assignee_id", dependent: :nullify
  has_many :created_tickets, class_name: "Ticket", foreign_key: "creator_id", dependent: :nullify
  has_many :requested_tickets, class_name: "Ticket", foreign_key: "requester_id", dependent: :nullify
  has_many :problems, dependent: :nullify
  has_many :comments, dependent: :destroy
  has_many :notifications, dependent: :destroy

  # Roles
  enum role: {
    service_desk_agent: 0,
    level_1_2_support: 1,
    team_leader: 2,
    level_3_support: 3,
    incident_manager: 4,
    problem_manager: 5,
    problem_coordinator: 6,
    change_manager: 7,
    change_coordinator: 8,
    department_manager: 9,
    general_manager: 10,
    system_admin: 11,
    domain_admin: 12
  }, _default: :service_desk_agent

  # Validations
  validates :email, presence: true, uniqueness: { scope: :organization_id, case_sensitive: false }
  validates :role, presence: true, inclusion: { in: roles.keys }
  validates :name, presence: true
  validates :username, presence: true, uniqueness: { scope: :organization_id }, allow_nil: true
  validates :password, length: { minimum: 8 }, if: -> { password.present? || new_record? }
  validates :password_confirmation, presence: true, if: -> { password.present? }

  validate :team_organization_matches_user_organization

  # Callbacks
  before_validation :set_default_role, on: :create
  before_validation :fix_invalid_role
  before_validation :log_role
  before_save :downcase_email
  before_save :ensure_auth_token

  after_update :notify_team_assignment, if: :saved_change_to_team_id?

  # Role-specific methods
  def is_admin?
    system_admin? || domain_admin?
  end

  def super_user?
    system_admin? || domain_admin?
  end

  def can_create_teams?
    system_admin? || level_1_2_support? || domain_admin?
  end

  def can_manage_organization?
    system_admin? || level_1_2_support? || general_manager? || domain_admin?
  end

  def can_create_tickets?(ticket_type)
    case ticket_type
    when "Incident", "Request"
      level_3_support? || team_leader? || level_1_2_support? || department_manager? || general_manager? || domain_admin?
    when "Problem"
      level_1_2_support? || department_manager? || general_manager? || domain_admin?
    else
      false
    end
  end

  def can_resolve_tickets?(ticket_type)
    can_create_tickets?(ticket_type)
  end

  def can_reassign_tickets?
    level_1_2_support? || department_manager? || general_manager? || domain_admin?
  end

  def can_change_urgency?
    team_leader? || level_1_2_support? || department_manager? || general_manager? || domain_admin?
  end

  def can_view_reports?(scope)
    case scope
    when :team
      team_leader? || level_1_2_support? || department_manager? || general_manager? || domain_admin?
    when :department
      department_manager? || general_manager? || domain_admin?
    when :organization
      general_manager? || domain_admin?
    else
      false
    end
  end

  def can_manage_users?
    department_manager? || general_manager? || system_admin? || domain_admin?
  end

  # User status management
  def deactivate!
    update!(active: false, auth_token: nil)
    Rails.logger.info "User #{email} (ID: #{id}) has been deactivated."
  end

  def activate!
    update!(active: true)
    Rails.logger.info "User #{email} (ID: #{id}) has been activated."
  end

  # User info
  def full_name
    name
  end

  def avatar_url
    return "https://example.com/default-avatar.png" unless avatar.attached?
    avatar.service_url rescue "https://example.com/default-avatar.png"
  end

  # Token management
  def regenerate_auth_token
    update!(auth_token: SecureRandom.hex(20))
  end

  # Class methods
  def self.admins
    where(role: [:system_admin, :domain_admin])
  end

  def self.find_by_credentials(email, password)
    user = find_by(email: email.downcase)
    user&.authenticate(password) ? user : nil
  end

  def unread_notifications_count(organization)
    notifications.for_organization(organization).unread.count
  end

  private

  def set_default_role
    self.role ||= :service_desk_agent
  end

  def downcase_email
    self.email = email.downcase if email.present?
  end

  def team_organization_matches_user_organization
    return unless team.present? && team.organization != organization
    errors.add(:team, "must belong to the same organization as the user")
  end

  def ensure_auth_token
    if auth_token.nil? && !skip_auth_token
      begin
        self.auth_token = SecureRandom.hex(20)
      rescue StandardError => e
        Rails.logger.error "Error generating auth token: #{e.message}"
        self.auth_token = "default_#{Time.now.to_i}"
      end
    end
  end

  def notify_team_assignment
    return if team.nil?
    notifications.create!(
      message: "You've been added to the team: #{team.name}",
      organization: organization,
      read: false,
      skip_email: true
    )
  end

  def fix_invalid_role
    db_role = attributes['role']
    if db_role.present? && !self.class.roles.values.include?(db_role.to_i)
      Rails.logger.warn "Fixing invalid role for user #{id}: #{db_role} not in #{self.class.roles.values}"
      self.role = :service_desk_agent
    end
  end

  def log_role
    Rails.logger.info "User #{id || 'new'} role before validation: #{role.inspect}, db value: #{attributes['role'].inspect}, enum: #{self.class.roles.inspect}"
  end
end