class User < ApplicationRecord
  has_secure_password
  belongs_to :organization
  belongs_to :creator, class_name: "User", foreign_key: "user_id"
  belongs_to :assignee, class_name: "User", optional: true
  belongs_to :team, optional: true # Tickets can be assigned to a team (optional)
  belongs_to :requester, class_name: "User"

  has_many :tickets, dependent: :destroy
  has_many :assigned_tickets, class_name: "Ticket", foreign_key: "assignee_id"
  has_many :created_tickets, class_name: "Ticket", foreign_key: "creator_id"
  has_many :requested_tickets, class_name: "Ticket", foreign_key: "requester_id"

  # Enum for roles using integers
  enum role: { admin: 0, teamlead: 1, agent: 2, viewer: 3 }, _prefix: :role

  # Validations
  validates :email, presence: true, uniqueness: true
  validates :role, inclusion: { in: roles.keys }
  validates :name, presence: true

  # Scopes
  scope :filter_by_role, ->(role) { role.present? ? where(role: role) : all }
  scope :by_organization, ->(organization_id) { where(organization_id: organization_id) }

  # Callbacks
  before_validation :set_default_role, on: :create

  def can_create_teams?
    admin? || super_user?
  end

  def teamlead?
    role == "teamlead"
  end

  private

  # Default role assignment
  def set_default_role
    self.role ||= :viewer
  end
end
