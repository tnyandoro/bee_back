# frozen_string_literal: true

# Create organization
greensoft_org = Organization.create!(
  name: "GreenSoft Solutions",
  subdomain: "greensoft-solutions",
  email: "contact@greensoft.com",
  phone_number: "555-123-4567",
  address: "123 Tech Lane, Innovation City",
  web_address: "https://greensoft.com"
)

# Create users
it_manager = User.create!(
  name: "IT Manager",
  username: "it.manager@greensoft.com",
  email: "it.manager@greensoft.com",
  password: "password123",
  password_confirmation: "password123",
  role: :service_desk_tl,
  organization: greensoft_org,
  auth_token: "itmanager_token_456"
)

support_tech = User.create!(
  name: "Support Tech",
  username: "support.tech@greensoft.com",
  email: "support.tech@greensoft.com",
  password: "password123",
  password_confirmation: "password123",
  role: :service_desk_agent,
  organization: greensoft_org,
  auth_token: "supporttech_token_789"
)

network_tech = User.create!(
  name: "Network Tech",
  username: "network@greensoft.com",
  email: "network@greensoft.com",
  password: "password123",
  password_confirmation: "password123",
  role: :assignee_lvl_3,
  organization: greensoft_org,
  auth_token: "networktech_token_012"
)

helpdesk = User.create!(
  name: "Helpdesk Agent",
  username: "helpdesk@greensoft.com",
  email: "helpdesk@greensoft.com",
  password: "password123",
  password_confirmation: "password123",
  role: :call_center_agent,
  organization: greensoft_org,
  auth_token: "helpdesk_token_345"
)

admin = User.create!(
  name: "System Admin",
  username: "admin@greensoft.com",
  email: "admin@greensoft.com",
  password: "password123",
  password_confirmation: "password123",
  role: :system_admin,
  organization: greensoft_org,
  auth_token: "admin_token_123"
)

# Create team
it_team = Team.create!(
  name: "IT Support",
  organization: greensoft_org
)

# Assign users to team
it_team.users << [it_manager, support_tech, network_tech, helpdesk]

# Create SLA policy
sla_policy = SlaPolicy.create!(
  organization: greensoft_org,
  priority: :critical,
  response_time: 60, # minutes
  resolution_time: 480 # minutes (8 hours)
)

# Create business hours
(1..5).each do |day|
  BusinessHour.create!(
    organization: greensoft_org,
    day_of_week: day,
    start_time: "09:00",
    end_time: "17:00"
  )
end

# Create tickets
tickets = [
  {
    title: "Email Client Not Working",
    description: "User reports email client crashing on launch.",
    ticket_type: "Incident",
    status: :assigned,
    priority: :critical,
    urgency: :medium,
    impact: :medium,
    creator: it_manager,
    requester: it_manager,
    assignee: support_tech,
    reported_at: Time.current - 2.hours,
    category: "Software",
    caller_name: "Jane",
    caller_surname: "Smith",
    caller_email: "jane.smith@greensoft.com",
    caller_phone: "555-987-6543",
    customer: "Internal IT",
    source: "Email",
    team: it_team,
    sla_policy: sla_policy
  },
  {
    title: "VPN Connection Issues",
    description: "User cannot connect to VPN from home office.",
    ticket_type: "Incident",
    status: :assigned,
    priority: :p2,
    urgency: :high,
    impact: :medium,
    creator: it_manager,
    requester: it_manager,
    assignee: network_tech,
    reported_at: Time.current - 1.hour,
    category: "Software",
    caller_name: "John",
    caller_surname: "Doe",
    caller_email: "john.doe@greensoft.com",
    caller_phone: "555-123-4567",
    customer: "Internal IT",
    source: "Phone",
    team: it_team,
    sla_policy: sla_policy
  },
  {
    title: "New Employee Setup",
    description: "Setup workstation and accounts for new hire.",
    ticket_type: "Request",
    status: :assigned,
    priority: :p4,
    urgency: :low,
    impact: :low,
    creator: it_manager,
    requester: it_manager,
    assignee: helpdesk,
    reported_at: Time.current - 30.minutes,
    category: "Software",
    caller_name: "HR",
    caller_surname: "Manager",
    caller_email: "hr@greensoft.com",
    caller_phone: "555-456-7890",
    customer: "HR",
    source: "Email",
    team: it_team,
    sla_policy: sla_policy
  }
]

Rails.logger.info "Creating tickets..."
tickets.each_with_index do |ticket_data, index|
  prefix = case ticket_data[:ticket_type].to_s
           when 'Incident' then 'INC'
           when 'Request' then 'REQ'
           when 'Problem' then 'PRB'
           else 'TKT'
           end
  ticket_number = "#{prefix}#{SecureRandom.alphanumeric(8).upcase}"
  
  ticket = Ticket.create!(
    title: ticket_data[:title],
    description: ticket_data[:description],
    ticket_type: ticket_data[:ticket_type],
    status: ticket_data[:status],
    priority: ticket_data[:priority],
    urgency: ticket_data[:urgency],
    impact: ticket_data[:impact],
    creator: ticket_data[:creator],
    requester: ticket_data[:requester],
    assignee: ticket_data[:assignee],
    organization: greensoft_org,
    reported_at: ticket_data[:reported_at],
    category: ticket_data[:category],
    caller_name: ticket_data[:caller_name],
    caller_surname: ticket_data[:caller_surname],
    caller_email: ticket_data[:caller_email],
    caller_phone: ticket_data[:caller_phone],
    customer: ticket_data[:customer],
    source: ticket_data[:source],
    team: ticket_data[:team],
    ticket_number: ticket_number,
    sla_policy: ticket_data[:sla_policy],
    response_due_at: ticket_data[:reported_at] + ticket_data[:sla_policy].response_time.minutes,
    resolution_due_at: ticket_data[:reported_at] + ticket_data[:sla_policy].resolution_time.minutes
  )
  Rails.logger.info "Created ticket: #{ticket.title} (#{ticket.ticket_number})"
  
  # Create creation notification for requester
  Notification.create!(
    user: ticket.requester,
    organization: greensoft_org,
    message: "New ticket created: #{ticket.title} (#{ticket.ticket_number})",
    notifiable: ticket,
    read: false,
    skip_email: true
  )
  Rails.logger.info "Created creation notification for ticket #{ticket.ticket_number} to #{ticket.requester.email}"
end

# Create assignment notifications
Rails.logger.info "Creating assignment notifications..."
Ticket.where(organization: greensoft_org).each do |ticket|
  if ticket.assignee
    Notification.create!(
      user: ticket.assignee,
      organization: greensoft_org,
      message: "You have been assigned a new ticket: #{ticket.title} (#{ticket.ticket_number})",
      notifiable: ticket,
      read: false,
      skip_email: true
    )
    Rails.logger.info "Created assignment notification for ticket #{ticket.ticket_number} assigned to #{ticket.assignee.email}"
  end
end