# Service object to create notifications for users
# frozen_string_literal: true
# 
#
class NotificationService
    def self.notify_user(user, organization, message, notifiable = nil)
      Notification.create!(
        user: user,
        organization: organization,
        message: message,
        notifiable: notifiable # Optional, if using polymorphic association
      )
    end
end