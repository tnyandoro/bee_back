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

  def ticket_assigned_for_requester(ticket, user)
    @ticket = ticket
    mail(
      to: user.email,
      subject: "New Ticket Assigned: #{@ticket.title}"
    )
  end

end
