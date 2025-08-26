# class TicketNotificationMailer < ApplicationMailer
#   default from: 'gsolve360@yahoo.com'

#   # Notify a user about a new ticket creation
#   def ticket_created(ticket, recipient)
#     @ticket = ticket
#     mail(
#       to: recipient.email,
#       subject: "New Ticket Created: #{@ticket.title}"
#     )
#   end

#   # Notify assignee(s) about ticket assignment
#   # recipient can be a User or a Team
#   def ticket_assigned(ticket, recipient)
#     @ticket = ticket
#     mail(
#       to: recipient_emails(recipient),
#       subject: "New Ticket Assigned: #{@ticket.title}"
#     )
#   end

#   # Notify a user about a generic notification
#   def notify_user(notification)
#     @notification = notification
#     mail(
#       to: @notification.user.email,
#       subject: "ITSM Notification: #{@notification.message.truncate(50)}"
#     )
#   end

#   private

#   def recipient_emails(recipient)
#     case recipient
#     when Team
#       recipient.users.pluck(:email)
#     when User
#       recipient.email
#     else
#       raise ArgumentError, "Invalid recipient: must be User or Team"
#     end
#   end
# end
