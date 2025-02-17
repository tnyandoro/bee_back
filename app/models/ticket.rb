# frozen_string_literal: true
class Ticket < ApplicationRecord
  belongs_to :organization
  belongs_to :user
  belongs_to :creator, class_name: "User", foreign_key: "creator_id"
  belongs_to :requester, class_name: "User", foreign_key: "requester_id"
  belongs_to :assignee, class_name: "User", foreign_key: "assignee_id"
  belongs_to :team, optional: true

  has_many :problems, dependent: :destroy

  enum status: { open: 0, assigned: 1, escalated: 2, closed: 3, suspended: 4, resolved: 5, pending: 6 }

  validates :title, :description, presence: true
  
  # Callbacks
  after_create :create_notifications

  # Scope to filter tickets by user and organization
  scope :for_user_in_organization, ->(user_id, organization_id) {
    where(user_id: user_id, organization_id: organization_id)
  }

  private

  def create_notifications
    # Notify the admin
    admin = organization.users.find_by(role: :admin)
    if admin
      Notification.create!(
        user: admin,
        organization: organization,
        message: "New ticket created: #{title}"
      )
    end

    # Notify the assignee (if assigned)
    if assignee
      Notification.create!(
        user: assignee,
        organization: organization,
        message: "You have been assigned to a new ticket: #{title}"
      )
    end
  end
end