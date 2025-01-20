# frozen_string_literal: true
class SendTicketAssignmentEmailsJob < ApplicationJob
  queue_as :default

  def perform(ticket, team, user)
    TicketMailer.ticket_assigned_to_team(ticket, team).deliver_now
    TicketMailer.ticket_assigned_to_user(ticket, user).deliver_now
  end
end
