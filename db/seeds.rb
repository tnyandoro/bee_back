# db/seeds.rb
puts "Clearing existing data..."
[Problem, Comment, Ticket, User, Team, Organization, BusinessHour, SlaPolicy].each(&:destroy_all)

# Create the organization
puts "Creating organization..."
organization = Organization.create!(
  name: "Example Corp",
  address: "123 Tech Park",
  email: "info@example.com",
  web_address: "https://example.com",
  subdomain: "example",
  phone_number: "+1234567890"
)

# Create teams
puts "Creating teams..."
teams = [
  { name: "IT Support" },
  { name: "Network Operations" },
  { name: "Help Desk" }
]

teams.each do |team_data|
  Team.create!(
    name: team_data[:name],
    organization: organization
  )
end

it_support = Team.find_by(name: "IT Support")
network_ops = Team.find_by(name: "Network Operations")
help_desk = Team.find_by(name: "Help Desk")

# Create business hours
puts "Creating business hours..."
(0..4).each do |day| # Weekdays only
  BusinessHour.create!(
    organization: organization,
    day_of_week: day,
    start_time: "09:00",
    end_time: "17:00"
  )
end

# Create SLA policies
puts "Creating SLA policies..."
{
  p1: { response_time: 60, resolution_time: 240 },   # 1hr response, 4hr resolve
  p2: { response_time: 240, resolution_time: 480 },  # 4hr response, 8hr resolve
  p3: { response_time: 480, resolution_time: 1440 }, # 8hr response, 24hr resolve
  p4: { response_time: 1440, resolution_time: 2880 } # 24hr response, 48hr resolve
}.each do |priority, times|
  SlaPolicy.create!(
    organization: organization,
    priority: SlaPolicy.priorities[priority],
    response_time: times[:response_time],
    resolution_time: times[:resolution_time]
  )
end

# Create users with proper team assignments
puts "Creating users..."
users = [
  # Admin (no team)
  {
    name: "Admin User",
    email: "admin@example.com",
    username: "admin",
    role: :admin,
    team: nil,
    department: "Executive",
    position: "System Administrator"
  },

  # IT Support Team
  {
    name: "IT Manager",
    email: "it.manager@example.com",
    username: "itmanager",
    role: :agent,
    team: it_support,
    department: "IT",
    position: "IT Manager"
  },
  {
    name: "Support Technician",
    email: "support.tech@example.com",
    username: "supporttech",
    role: :agent,
    team: it_support,
    department: "IT",
    position: "Support Technician"
  },

  # Network Operations Team
  {
    name: "Network Engineer",
    email: "network@example.com",
    username: "networkeng",
    role: :agent,
    team: network_ops,
    department: "IT",
    position: "Network Engineer"
  },

  # Help Desk Team
  {
    name: "Help Desk Agent",
    email: "helpdesk@example.com",
    username: "helpdesk",
    role: :agent,
    team: help_desk,
    department: "Support",
    position: "Help Desk Agent"
  },

  # Viewer (no team)
  {
    name: "Auditor",
    email: "auditor@example.com",
    username: "auditor",
    role: :viewer,
    team: nil,
    department: "Compliance",
    position: "Auditor"
  }
]

users.each do |user_data|
  User.create!(
    name: user_data[:name],
    email: user_data[:email],
    password: "password123",
    username: user_data[:username],
    role: user_data[:role],
    department: user_data[:department],
    position: user_data[:position],
    organization: organization,
    team: user_data[:team]
  )
  puts "Created #{user_data[:role]} user: #{user_data[:email]}"
end

admin = User.find_by(email: "admin@example.com")
it_manager = User.find_by(email: "it.manager@example.com")
support_tech = User.find_by(email: "support.tech@example.com")
network_eng = User.find_by(email: "network@example.com")
helpdesk = User.find_by(email: "helpdesk@example.com")

# Create tickets with proper team assignments
puts "Creating tickets..."
tickets = [
  # IT Support Ticket
  {
    title: "Email Client Not Working",
    description: "Outlook keeps crashing when opening attachments",
    ticket_type: :incident,
    status: :open,
    priority: 2,
    urgency: :high,
    impact: :medium,
    creator: admin,
    requester: it_manager,
    assignee: support_tech,
    reported_at: 2.hours.ago,
    category: "Software",
    caller_name: "Sarah",
    caller_surname: "Johnson",
    caller_email: "sarah.j@example.com",
    caller_phone: "555-0101",
    customer: "Marketing",
    source: "Email",
    team: it_support
  },

  # Network Operations Ticket
  {
    title: "VPN Connection Issues",
    description: "Cannot connect to corporate VPN from remote locations",
    ticket_type: :incident,
    status: :open,
    priority: 1,
    urgency: :high,
    impact: :high,
    creator: admin,
    requester: it_manager,
    assignee: network_eng,
    reported_at: 1.hour.ago,
    category: "Network",
    caller_name: "Michael",
    caller_surname: "Brown",
    caller_email: "michael.b@example.com",
    caller_phone: "555-0202",
    customer: "Remote Team",
    source: "Phone",
    team: network_ops
  },

  # Help Desk Ticket
  {
    title: "New Employee Setup",
    description: "Need laptop and account setup for new hire starting Monday",
    ticket_type: :service_request,
    status: :open,
    priority: 3,
    urgency: :medium,
    impact: :low,
    creator: admin,
    requester: it_manager,
    assignee: helpdesk,
    reported_at: Time.current,
    category: "Onboarding",
    caller_name: "Jessica",
    caller_surname: "Wilson",
    caller_email: "jessica.w@example.com",
    caller_phone: "555-0303",
    customer: "HR",
    source: "Portal",
    team: help_desk
  }
]

tickets.each_with_index do |ticket_data, index|
  ticket = Ticket.create!(
    title: ticket_data[:title],
    description: ticket_data[:description],
    ticket_type: ticket_data[:ticket_type],
    status: ticket_data[:status],
    priority: ticket_data[:priority],
    urgency: ticket_data[:urgency],
    impact: ticket_data[:impact],
    creator_id: ticket_data[:creator].id,
    requester_id: ticket_data[:requester].id,
    assignee_id: ticket_data[:assignee]&.id,
    organization: organization,
    reported_at: ticket_data[:reported_at],
    category: ticket_data[:category],
    caller_name: ticket_data[:caller_name],
    caller_surname: ticket_data[:caller_surname],
    caller_email: ticket_data[:caller_email],
    caller_phone: ticket_data[:caller_phone],
    customer: ticket_data[:customer],
    source: ticket_data[:source],
    team_id: ticket_data[:team].id,
    ticket_number: "TICKET-#{Time.current.to_i + index}"
  )
  puts "Created ticket: #{ticket.title} (#{ticket.ticket_number})"
end

# Create comments
puts "Creating comments..."
ticket = Ticket.first
if ticket
  Comment.create!(
    content: "I've tried reinstalling Outlook but the issue persists.",
    user: support_tech,
    ticket: ticket
  )
  Comment.create!(
    content: "Please check for Windows updates and try again.",
    user: it_manager,
    ticket: ticket
  )
  puts "Created sample comments for ticket #{ticket.ticket_number}"
end

# Create problems
puts "Creating problems..."
ticket = Ticket.second # Use the VPN ticket
if ticket
  Problem.create!(
    description: "VPN server capacity issue during peak hours",
    ticket: ticket,
    user: network_eng,
    creator: network_eng,
    team: network_ops,
    organization: organization
  )
  puts "Created problem for ticket #{ticket.ticket_number}"
end

puts "Seeding completed successfully!"