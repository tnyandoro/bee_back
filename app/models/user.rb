# app/models/user.rb
class User < ApplicationRecord
  has_secure_password
  has_secure_token :auth_token # For API authentication

  # Add an accessor to skip auth_token generation
  attr_accessor :skip_auth_token

  # Associations
  belongs_to :organization
  belongs_to :team, optional: true

  has_many :tickets, dependent: :destroy
  has_many :assigned_tickets, class_name: "Ticket", foreign_key: "assignee_id"
  has_many :created_tickets, class_name: "Ticket", foreign_key: "creator_id"
  has_many :requested_tickets, class_name: "Ticket", foreign_key: "requester_id"
  has_many :problems, dependent: :nullify # If problems are assigned to users
  has_many :comments, class_name: 'Comment', dependent: :destroy # Fixing the association
  has_many :notifications, dependent: :destroy # If users receive notifications

  # Roles
  enum role: { admin: 0, super_user: 1, teamlead: 2, agent: 3, viewer: 4 }, _prefix: :role

  # Validations
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :role, inclusion: { in: roles.keys }
  validates :name, presence: true
  validates :password, length: { minimum: 8 }, if: -> { password.present? }
  validate :team_organization_matches_user_organization

  # Callbacks
  before_create :generate_auth_token, unless: :skip_auth_token?

  # Role-specific methods
  def admin?
    role == "admin"
  end

  def super_user?
    role == "super_user"
  end

  def teamlead?
    role == "teamlead"
  end

  def agent?
    role == "agent"
  end

  def viewer?
    role == "viewer"
  end

  def can_create_teams?
    admin? || super_user?
  end

  def can_manage_organization?
    admin? || super_user?
  end

  # Deactivate user instead of deleting
  def deactivate!
    update!(active: false)
  end

  # Return user's full name
  def full_name
    name # Replace with `"#{first_name} #{last_name}"` if you have separate fields
  end

  # Return avatar URL (if applicable)
  def avatar_url
    nil # Replace with actual logic
  end

  # Class methods
  def self.admins
    where(role: :admin)
  end

  private

  # Default role assignment
  def set_default_role
    self.role ||= :viewer
  end

  # Ensure team belongs to the same organization as the user
  def team_organization_matches_user_organization
    return unless team.present? && team.organization != organization

    errors.add(:team, "must belong to the same organization as the user")
  end

  # Conditionally generate auth_token
  def generate_auth_token
    self.auth_token = SecureRandom.hex(10) if self.auth_token.nil?
  end

  # Define skip_auth_token? method
  def skip_auth_token?
    self.skip_auth_token == true
  end
end
