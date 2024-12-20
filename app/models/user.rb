class User < ApplicationRecord
  belongs_to :organization
  has_secure_password

  has_many :tickets, dependent: :destroy

  # Enum for roles with a prefix to avoid method conflicts
  enum role: { admin: 'admin', teamlead: 'teamlead', agent: 'agent', viewer: 'viewer' }, _prefix: :role

  # Validations
  validates :email, presence: true, uniqueness: true
  validates :role, inclusion: { in: roles.keys }
  validates :name, presence: true

  # Scopes
  scope :filter_by_role, ->(role) { role.present? ? where(role: role) : all }
  scope :by_organization, ->(organization_id) { where(organization_id: organization_id) }

  # Callbacks
  before_validation :set_default_role, on: :create

  private

  # Default role assignment
  def set_default_role
    self.role ||= 'viewer'
  end
end
