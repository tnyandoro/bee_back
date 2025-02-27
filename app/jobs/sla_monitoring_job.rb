# app/jobs/sla_monitoring_job.rb
class SlaMonitoringJob < ApplicationJob
    queue_as :default
  
    def perform
      Organization.find_each do |org|
        org.tickets.where.not(status: ['closed', 'resolved']).find_each do |ticket|
          ticket.calculate_sla_dates
          escalate_ticket(ticket) if ticket.sla_breached?
        end
      end
    end
  
    private
  
    def escalate_ticket(ticket)
      return if ticket.escalation_level > 2
      
      ticket.update!(
        escalation_level: ticket.escalation_level + 1,
        status: :escalated
      )
      Notification.create!(
        user: ticket.team.teamlead,
        organization: ticket.organization,
        message: "Ticket ##{ticket.id} breached SLA - Escalated to level #{ticket.escalation_level}"
      )
    end
  end