class User < ApplicationRecord
  has_secure_password
  belongs_to :organization
  belongs_to :team, optional: true

<<<<<<< HEAD
  # Associations
  belongs_to :organization
  belongs_to :team, optional: true

  has_many :tickets, dependent: :destroy
  has_many :assigned_tickets, class_name: "Ticket", foreign_key: "assignee_id"
  has_many :created_tickets, class_name: "Ticket", foreign_key: "creator_id"
  has_many :requested_tickets, class_name: "Ticket", foreign_key: "requester_id"

  # Roles
=======
  has_many :tickets, dependent: :destroy
  has_many :assigned_tickets, class_name: "Ticket", foreign_key: "assignee_id"
  has_many :created_tickets, class_name: "Ticket", foreign_key: "creator_id"
  has_many :requested_tickets, class_name: "Ticket", foreign_key: "requester_id"

  # Add super_user to the enum
>>>>>>> origin/main
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
  scope :by_role_and_organization, ->(role, organization_id) {
    where(role: role, organization_id: organization_id)
  }
  scope :by_roles, ->(*roles) { where(role: roles) }
  scope :search, ->(query) {
    where("name ILIKE ? OR email ILIKE ?", "%#{query}%", "%#{query}%")
  }
  scope :with_tickets, -> {
    left_joins(:tickets, :assigned_tickets, :created_tickets, :requested_tickets)
      .where("tickets.id IS NOT NULL OR assigned_tickets_tickets.id IS NOT NULL OR created_tickets_tickets.id IS NOT NULL OR requested_tickets_tickets.id IS NOT NULL")
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
  def can_create_teams?
    admin? || super_user?
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

  # Class methods
  def self.admins
    where(role: :admin)
  end

  # Fetch users by role and team
  def self.by_role_and_team(role, team_id)
    where(role: role, team_id: team_id)
  end

  # Fetch users with no team
  def self.without_team
    where(team_id: nil)
  end

  # Fetch users with specific roles and no team
  def self.by_roles_without_team(*roles)
    where(role: roles, team_id: nil)
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