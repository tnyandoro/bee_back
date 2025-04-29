class User < ApplicationRecord
  # Authentication
  has_secure_password
  has_secure_token :auth_token # Note: This requires the `has_secure_token` gem or custom implementation

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

  # Roles (updated to match your schema where role is an integer)
  enum role: { 
    admin: 0, 
    super_user: 1, 
    team_lead: 2,  # Changed from teamlead to team_lead
    agent: 3, 
    viewer: 4 
  }, _prefix: :role

  # Validations
  validates :email, presence: true, uniqueness: { scope: :organization_id, case_sensitive: false }
  validates :role, presence: true, inclusion: { in: roles.keys }
  validates :name, presence: true
  validates :username, presence: true, uniqueness: { scope: :organization_id }, allow_nil: true
  validates :password, length: { minimum: 8 }, if: -> { password.present? || new_record? }
  validate :team_organization_matches_user_organization

  # Callbacks
  before_validation :set_default_role, on: :create
  before_save :downcase_email
  before_save :ensure_auth_token

  # Role-specific methods
  def admin?
    role_admin? || role_super_user?
  end
  
  def super_user? = role_super_user?
  def teamlead? = role_team_lead?
  def agent? = role_agent?
  def viewer? = role_viewer?

  def can_create_teams?
    admin? || super_user?
  end

  def can_manage_organization?
    admin? || super_user?
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
    where(role: :admin)
  end

  def self.find_by_credentials(email, password)
    user = find_by(email: email.downcase)
    user&.authenticate(password) ? user : nil
  end

  private

  def set_default_role
    self.role ||= :viewer
  end

  def downcase_email
    # Enhanced nil protection
    self.email = email.downcase if email.present?
  end

  def team_organization_matches_user_organization
    return unless team.present? && team.organization != organization
    errors.add(:team, "must belong to the same organization as the user")
  end

  def ensure_auth_token
    # Only generate token if it's nil and we're not skipping token generation
    if auth_token.nil? && !skip_auth_token
      begin
        self.auth_token = SecureRandom.hex(20)
      rescue StandardError => e
        Rails.logger.error "Error generating auth token: #{e.message}"
        # Set a default token in case of error
        self.auth_token = "default_#{Time.now.to_i}"
      end
    end
  end
end
