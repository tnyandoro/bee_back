# frozen_string_literal: true
class TicketMailer < ApplicationMailer
  def ticket_assigned_to_team(ticket, user)
    return unless user&.email && ticket # Skip if user or ticket is missing
    @ticket = ticket
    @user = user
    @team_name = ticket.team&.name || "Unspecified Team"
    @attachment = ticket.attachment&.attached? ? ticket.attachment : nil
    @files = ticket.files&.attached? ? ticket.files : []
    mail(
      to: user.email,
      subject: "New Ticket Assigned to Team: #{@ticket.title}"
    )
  end

  def ticket_assigned_to_user(ticket, user)
    return unless user&.email && ticket # Skip if user or ticket is missing
    @ticket = ticket
    @user = user
    @team_name = ticket.team&.name || "Unspecified Team"
    @attachment = ticket.attachment&.attached? ? ticket.attachment : nil
    @files = ticket.files&.attached? ? ticket.files : []
    mail(
      to: user.email,
      subject: "New Ticket Assigned to You: #{@ticket.title}"
    )
  end
end