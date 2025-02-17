class NotificationMailer < ApplicationMailer
    default from: "itsm@example.com"
  
    def ticket_created_notification(ticket, recipient)
      @ticket = ticket
      @recipient = recipient
      mail(to: recipient.email, subject: "New Ticket Created: #{@ticket.title}")
    end
  end