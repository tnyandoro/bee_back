# app/models/ticket.rb
# frozen_string_literal: true
class Ticket < ApplicationRecord
  belongs_to :organization
  belongs_to :creator, class_name: "User", foreign_key: "creator_id"
  belongs_to :requester, class_name: "User", foreign_key: "requester_id"
  belongs_to :assignee, class_name: "User", foreign_key: "assignee_id", optional: true
  belongs_to :team, optional: true

  has_many :problems, dependent: :destroy
  has_many :comments, dependent: :destroy

  enum status: { open: 0, assigned: 1, escalated: 2, closed: 3, suspended: 4, resolved: 5, pending: 6 }

  validates :title, :description, presence: true
  validates :user_id, presence: true

  # Callbacks
  after_create :create_notifications

  # Scope to filter tickets by creator and organization (updated from user_id)
  scope :for_user_in_organization, ->(user_id, organization_id) {
    where(creator_id: user_id, organization_id: organization_id)
  }

  private

  def create_notifications
    admin = organization.users.find_by(role: :admin)
    if admin
      Notification.create!(
        user: admin,
        organization: organization,
        message: "New ticket created: #{title}"
      )
    end

    if assignee
      Notification.create!(
        user: assignee,
        organization: organization,
        message: "You have been assigned to a new ticket: #{title}"
      )
    end
  end
end
