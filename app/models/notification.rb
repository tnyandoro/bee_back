# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :organization
  belongs_to :notifiable, polymorphic: true, optional: true

  validates :user, :organization, :message, presence: true
  validates :read, inclusion: { in: [true, false] }

  before_validation :set_defaults
  after_create_commit :broadcast_to_user

  scope :unread, -> { where(read: false) }
  scope :for_organization, ->(org) { where(organization_id: org.id) }

  self.ignored_columns += ["ticket_id"]

  private

  def broadcast_to_user
    NotificationChannel.broadcast_to(
      user,
      {
        id: id,
        message: message,
        read: read,
        created_at: created_at,
        notifiable: {
          id: notifiable&.id,
          type: notifiable&.class&.name,
          ticket_number: notifiable&.try(:ticket_number),
          title: notifiable&.try(:title)
        }
      }
    )
  end

  def set_defaults
    self.read ||= false
  end
end