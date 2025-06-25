# frozen_string_literal: true
class TicketMailer < ApplicationMailer
    default from: 'notifications@gssitsm.com'

    def ticket_created(ticket)
      @ticket = ticket
      @organization = ticket.organization
  
      mail(
        to: @ticket.assignee&.email || "fallback@example.com",
        subject: "New Ticket Created: #{@ticket.title}"
      )
    end
  
    def ticket_assigned_to_team(ticket, team)
      @ticket = ticket
      @team = team
      mail(to: team.members.pluck(:email), subject: "New Ticket Assigned to Your Team: #{@ticket.title}")
    end
  
    def ticket_assigned_to_user(ticket, user)
      @ticket = ticket
      @user = user
      mail(to: user.email, subject: "You Have Been Assigned a New Ticket: #{@ticket.title}")
    end
end