# frozen_string_literal: true

class Notification < ApplicationRecord
  # Attributes
  attr_accessor :skip_email

  # Associations
  belongs_to :user
  belongs_to :organization
  belongs_to :notifiable, polymorphic: true, optional: true

  # Validations
  validates :user, :organization, :message, presence: true
  validates :read, inclusion: { in: [true, false] }

  # Callbacks
  before_validation :set_defaults
  after_create_commit :broadcast_to_user unless ENV['RAILS_ENV'] == 'test' || Rails.env.development?
  after_create_commit :send_email

  # Scopes
  scope :unread, -> { where(read: false) }
  scope :for_organization, ->(org) { where(organization_id: org.id) }

  # Ignored columns
  self.ignored_columns += ["ticket_id"]

  private

  def broadcast_to_user
    if defined?(NotificationChannel)
      NotificationChannel.broadcast_to(
        user,
        {
          id: id,
          message: message,
          read: read,
          created_at: created_at.iso8601, # For React compatibility
          notifiable: {
            id: notifiable&.id,
            type: notifiable&.class&.name,
            ticket_number: notifiable&.try(:ticket_number),
            title: notifiable&.try(:title)
          }
        }
      )
    end
  end

  def send_email
    NotificationMailer.notify_user(self).deliver_later if user.receive_email_notifications && !skip_email
  end

  def set_defaults
    self.read ||= false
  end
end