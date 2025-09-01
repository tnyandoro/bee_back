class NotificationMailer < ApplicationMailer
    default from: 'gsolve360@​yahoo.com'
  
    def ticket_created_notification(ticket, recipient)
      @ticket = ticket
      @recipient = recipient
      mail(to: recipient.email, subject: "New Ticket Created: #{@ticket.title}")
    end

    def notify_user(notification)
      @notification = notification
      mail(to: @notification.user.email, subject: "ITSM Notification: #{@notification.message.truncate(50)}")
    end

    def notify_caller(name, email, message)
      @name = name
      @message = message
      mail(to: email, subject: "ITSM Notification: #{@message.truncate(50)}")
    end
end