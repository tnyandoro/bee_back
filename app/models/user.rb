# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password
  has_secure_token :auth_token # For API authentication

  # Associations
  belongs_to :organization
  belongs_to :team, optional: true

  has_many :tickets, dependent: :destroy
  has_many :assigned_tickets, class_name: "Ticket", foreign_key: "assignee_id"
  has_many :created_tickets, class_name: "Ticket", foreign_key: "creator_id"
  has_many :requested_tickets, class_name: "Ticket", foreign_key: "requester_id"
  has_many :problems, dependent: :nullify # If problems are assigned to users
  has_many :comments, dependent: :destroy # If users can comment on tickets/problems
  has_many :notifications, dependent: :destroy # If users receive notifications

  # Roles
  enum role: { admin: 0, super_user: 1, teamlead: 2, agent: 3, viewer: 4 }, _prefix: :role

  # Validations
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :role, inclusion: { in: roles.keys }
  validates :name, presence: true
  validates :password, length: { minimum: 8 }, if: -> { password.present? }
  validate :team_organization_matches_user_organization

  # Scopes
  scope :filter_by_role, ->(role) { role.present? ? where(role: role) : all }
  scope :by_organization, ->(organization_id) { where(organization_id: organization_id) }
  scope :by_team, ->(team_id) { where(team_id: team_id) }
  scope :by_roles, ->(*roles) { where(role: roles) }
  scope :by_role_and_organization, ->(role, organization_id) {
    where(role: role, organization_id: organization_id)
  }
  scope :by_role_and_team, ->(role, team_id) { where(role: role, team_id: team_id) }
  scope :without_team, -> { where(team_id: nil) }
  scope :by_roles_without_team, ->(*roles) { where(role: roles, team_id: nil) }
  scope :search, ->(query) {
    where("name ILIKE ? OR email ILIKE ?", "%#{query}%", "%#{query}%")
  }
  scope :with_tickets, -> {
    left_joins(:created_tickets, :assigned_tickets, :requested_tickets)
      .where("tickets.id IS NOT NULL OR assigned_tickets_tickets.id IS NOT NULL OR requested_tickets_tickets.id IS NOT NULL")
      .distinct
  }

  # Callbacks
  before_validation :set_default_role, on: :create

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
    # Example: "https://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}?d=identicon"
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
end
