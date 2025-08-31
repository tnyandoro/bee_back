class SendTicketAssignmentEmailsJob < ApplicationJob
  queue_as :default

  def perform(ticket_id, team_id, user_id)
    ticket = Ticket.find_by(id: ticket_id)
    team = Team.find_by(id: team_id)
    user = User.find_by(id: user_id)
    
    return unless ticket # stop if ticket not found

    requester = User.find_by(id: ticket.requester_id)

    # Send email to each team member individually
    if team
      team.users.find_each do |team_member|
        TicketMailer.ticket_assigned_to_team(ticket, team_member).deliver_later
      end
    end

    # Send email to individual user
    TicketMailer.ticket_assigned_to_user(ticket, user).deliver_later if user

    # Send email to requester user
    TicketMailer.ticket_assigned_for_requester(ticket, requester).deliver_later if requester && ticket.assignee_id != ticket.requester_id
  end
end
