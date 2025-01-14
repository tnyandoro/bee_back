class User < ApplicationRecord
  has_secure_password
  belongs_to :organization
  belongs_to :team, optional: true

  has_many :tickets, dependent: :destroy
  has_many :assigned_tickets, class_name: "Ticket", foreign_key: "assignee_id"
  has_many :created_tickets, class_name: "Ticket", foreign_key: "creator_id"
  has_many :requested_tickets, class_name: "Ticket", foreign_key: "requester_id"

  # Add super_user to the enum
  enum role: { admin: 0, super_user: 1, teamlead: 2, agent: 3, viewer: 4 }, _prefix: :role

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