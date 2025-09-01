class TicketMailer < ApplicationMailer
  def ticket_assigned_to_team(ticket, user)
    @ticket = ticket
    mail(
      to: user.email,
      subject: "New Ticket Assigned: #{@ticket.title}"
    )
  end

  def ticket_assigned_to_user(ticket, user)
    @ticket = ticket
    mail(
      to: user.email,
      subject: "New Ticket Assigned: #{@ticket.title}"
    )
  end

  def ticket_assigned_for_requester(ticket, user, assignee)
    @ticket = ticket
    @user = user
    @assignee = assignee
    mail(
      to: user.email,
      subject: "New Ticket Assigned: #{@ticket.title}"
    )
  end

  def ticket_assigned_for_caller(ticket)
    @ticket = ticket
    @name = ticket.caller_name
    @surname = ticket.caller_surname
    @phone = ticket.caller_phone
    mail(
      to: ticket.caller_email,
      subject: "New Ticket Assigned: #{@ticket.title}"
    )
  end

end
