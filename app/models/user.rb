class User < ApplicationRecord
  # Authentication
  has_secure_password
  has_secure_token :auth_token
  has_one_attached :avatar

  attr_accessor :skip_auth_token

  # Associations
  belongs_to :organization
  belongs_to :team, optional: true
  belongs_to :department, optional: true

  has_many :tickets, dependent: :destroy
  has_many :assigned_tickets, class_name: "Ticket", foreign_key: "assignee_id", dependent: :nullify
  has_many :created_tickets, class_name: "Ticket", foreign_key: "creator_id", dependent: :nullify
  has_many :requested_tickets, class_name: "Ticket", foreign_key: "requester_id", dependent: :nullify
  has_many :problems, dependent: :nullify
  has_many :comments, dependent: :destroy
  has_many :notifications, dependent: :destroy

  # Roles
  enum role: {
    # Basic support roles
    call_center_agent: 0,          # Handles initial call screening
    service_desk_agent: 1,         # First line of technical support
    service_desk_tl: 2,            # Team lead for service desk
    assignee_lvl_1_2: 3,           # Technical support levels 1-2
    assignee_lvl_3: 4,             # Advanced technical support
    assignment_group_tl: 5,        # Team lead for technical groups
    
    # Management roles
    service_desk_manager: 6,       # Oversees service desk operations
    incident_manager: 7,           # Manages incident resolution
    problem_manager: 8,            # Oversees problem management
    change_manager: 9,             # Manages change processes
    department_manager: 10,        # Department-level oversight
    general_manager: 11,           # Organization-wide management
    
    # Administrative roles
    sub_domain_admin: 12,          # Manages specific domain areas
    domain_admin: 13,              # Full domain administration
    system_admin: 14               # Full system access
  }, _prefix: :role, _default: :call_center_agent

  # Validations
  validates :email, presence: true, uniqueness: { scope: :organization_id, case_sensitive: false }
  validates :role, inclusion: { in: roles.keys }, presence: true
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

  # --- NEW PERMISSION METHODS BASED ON ROLE MATRIX ---
  
  # Dashboard access
  def can_access_admin_dashboard?
    role_domain_admin? || role_sub_domain_admin?
  end
  
  def can_access_main_dashboard?
    !role_domain_admin? && !role_sub_domain_admin?
  end
  
  # Ticket permissions
  def can_create_ticket?
    role_call_center_agent? || role_service_desk_agent? || 
    role_service_desk_tl? || role_service_desk_manager? || 
    role_incident_manager?
  end
  
  def can_view_all_tickets?
    role_service_desk_agent? || role_service_desk_tl? || 
    role_service_desk_manager? || role_incident_manager? || 
    role_problem_manager?
  end
  
  def can_view_assigned_tickets?
    role_assignee_lvl_1_2? || role_assignee_lvl_3? || 
    role_assignment_group_tl?
  end
  
  # Incidents overview
  def can_access_incidents_overview?
    role_service_desk_agent? || role_service_desk_tl? || 
    role_assignee_lvl_1_2? || role_assignee_lvl_3? || 
    role_assignment_group_tl? || role_service_desk_manager? || 
    role_incident_manager? || role_problem_manager?
  end
  
  # Knowledge Base
  def can_access_knowledge_base?
    true # All roles can access KB
  end
  
  # Problem management
  def can_create_problem?
    role_assignee_lvl_3? || role_assignment_group_tl? || role_problem_manager?
  end
  
  def can_access_problems_overview?
    role_assignee_lvl_1_2? || role_assignee_lvl_3? || 
    role_assignment_group_tl? || role_service_desk_manager? || 
    role_incident_manager? || role_problem_manager?
  end
  
  def can_view_problems_only?
    role_assignee_lvl_1_2? || role_service_desk_manager? || 
    role_incident_manager?
  end
  
  # Settings
  def can_access_settings?
    true # All roles can access user settings
  end
  
  def can_access_admin_settings?
    role_domain_admin? || role_sub_domain_admin?
  end
  
  # Profile access
  def can_view_own_profile?
    true # All roles can view their profile
  end
  
  def can_edit_own_profile?
    role_domain_admin? || role_sub_domain_admin?
  end
  
  # User profiles (view only for most)
  def can_view_user_profiles?
    role_service_desk_agent? || role_assignee_lvl_1_2? || 
    role_assignee_lvl_3? || role_assignment_group_tl? || 
    role_service_desk_manager? || role_incident_manager? || 
    role_problem_manager? || role_department_manager? || 
    role_general_manager? || role_sub_domain_admin? || 
    role_domain_admin? || role_system_admin?
  end

  # --- EXISTING METHODS UPDATED FOR CONSISTENCY ---
  
  def is_admin?
    role_system_admin? || role_domain_admin? || role_sub_domain_admin? || 
    role_general_manager? || role_department_manager?
  end
  
  def super_user?
    role_system_admin? || role_domain_admin?
  end
  
  def can_create_teams?
    role_system_admin? || role_domain_admin? || role_service_desk_manager? || 
    role_department_manager?
  end

  def can_manage_organization?
    role_system_admin? || role_domain_admin? || role_general_manager? || 
    role_department_manager?
  end

  def can_create_tickets?(ticket_type)
    case ticket_type
    when "Incident", "Request"
      role_system_admin? || role_domain_admin? || role_assignee_lvl_3? || 
      role_assignment_group_tl? || role_assignee_lvl_1_2? || 
      role_department_manager? || role_general_manager?
    when "Problem"
      role_system_admin? || role_domain_admin? || role_problem_manager? || 
      role_department_manager? || role_general_manager?
    else
      false
    end
  end

  def can_resolve_tickets?(ticket_type)
    can_create_tickets?(ticket_type)
  end

  def can_reassign_tickets?
    role_system_admin? || role_assignee_lvl_1_2? || role_department_manager? || 
    role_general_manager? || role_domain_admin?
  end
  
  def can_change_urgency?
    role_service_desk_tl? || role_assignee_lvl_1_2? || role_department_manager? || 
    role_general_manager? || role_domain_admin?
  end
  
  def can_view_reports?(scope)
    case scope
    when :team
      role_system_admin? || role_service_desk_tl? || role_assignee_lvl_1_2? || 
      role_department_manager? || role_general_manager? || role_domain_admin?
    when :department
      role_system_admin? || role_department_manager? || role_general_manager? || 
      role_domain_admin?
    when :organization
      role_system_admin? || role_general_manager? || role_domain_admin?
    else
      false
    end
  end

  def can_manage_incidents?
    role_incident_manager? || role_system_admin? || role_domain_admin? || 
    role_service_desk_manager?
  end

  def can_manage_problems?
    role_problem_manager? || role_system_admin? || role_domain_admin?
  end

  def can_manage_changes?
    role_change_manager? || role_system_admin? || role_domain_admin?
  end

  def can_access_call_center?
    role_call_center_agent? || role_service_desk_agent? || role_service_desk_tl? || 
    role_service_desk_manager? || is_admin?
  end

  def can_escalate_tickets?
    role_assignee_lvl_1_2? || role_assignee_lvl_3? || role_assignment_group_tl? || 
    role_service_desk_tl? || is_admin?
  end

  def can_manage_users?
    role_department_manager? || role_general_manager? || role_system_admin? || 
    role_domain_admin?
  end

  # --- SCOPES ---
  
  def self.management_team
    where(role: [
      :service_desk_manager, 
      :incident_manager, 
      :problem_manager, 
      :change_manager,
      :department_manager,
      :general_manager
    ])
  end

  def self.technical_staff
    where(role: [
      :assignee_lvl_1_2,
      :assignee_lvl_3,
      :assignment_group_tl
    ])
  end

  def self.support_staff
    where(role: [
      :call_center_agent,
      :service_desk_agent,
      :service_desk_tl
    ])
  end

  # --- CORE USER METHODS ---
  
  def deactivate!
    update!(active: false, auth_token: nil)
    Rails.logger.info "User #{email} (ID: #{id}) has been deactivated."
  end

  def activate!
    update!(active: true)
    Rails.logger.info "User #{email} (ID: #{id}) has been activated."
  end

  def full_name
    name
  end

  def avatar_url
    return "https://example.com/default-avatar.png" unless avatar.attached?
    avatar.service_url rescue "https://example.com/default-avatar.png"
  end

  def regenerate_auth_token
    update!(auth_token: SecureRandom.hex(20))
  end

  def self.admins
    where(role: [:system_admin, :domain_admin, :sub_domain_admin])
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
      Rails.logger.warn "Fixing invalid role for user #{id}: #{db_role} not in #{self.class.roles.inspect}"
      self.role = :service_desk_agent
    end
  end

  def log_role
    Rails.logger.info "User #{id || 'new'} role before validation: #{role.inspect}, db value: #{attributes['role'].inspect}, enum: #{self.class.roles.inspect}"
  end
end