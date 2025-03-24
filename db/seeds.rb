# db/seeds.rb
puts "Clearing existing data..."
Problem.destroy_all
Ticket.destroy_all
User.destroy_all
Team.destroy_all
Organization.destroy_all

# Create the organization first
puts "Creating organization..."
organization = Organization.create!(
  name: "Example Org",
  address: "123 Main St",
  email: "info@example.com",
  web_address: "https://example.com",
  subdomain: "example"
)

# Create teams
puts "Creating teams..."
it_team = Team.create!(
  name: "IT Team",
  organization: organization
)

support_team = Team.create!(
  name: "Support Team",
  organization: organization
)

# Create the admin user with organization association
puts "Creating admin user..."
admin_user = User.create!(
  name: "Admin User",
  email: "admin@example.com",
  password: "password123", # Meets 8-character minimum
  username: "adminuser", # Required by validation
  role: :admin, # Use symbol to match enum
  department: "Management",
  position: "Admin",
  organization: organization
)
puts "Created admin user: #{admin_user.email}"

# Only the admin can create other users
if admin_user.persisted?
  puts "Creating other users..."
  roles = [
    { name: "Teamlead User", email: "teamlead@example.com", username: "teamleaduser", role: :teamlead, team: it_team },
    { name: "Agent User", email: "agent@example.com", username: "agentuser", role: :agent, team: support_team },
    { name: "Viewer User", email: "viewer@example.com", username: "vieweruser", role: :viewer }
  ]

  roles.each do |user_data|
    User.create!(
      name: user_data[:name],
      email: user_data[:email],
      password: "password123",
      username: user_data[:username],
      role: user_data[:role],
      organization: organization,
      team: user_data[:team]
    )
    puts "Created #{user_data[:role]} user: #{user_data[:email]}"
  end

  # Fetch users for ticket creation
  teamlead_user = User.find_by(email: "teamlead@example.com")
  agent_user = User.find_by(email: "agent@example.com")

  # Create tickets
  puts "Creating tickets..."
  ticket1 = Ticket.create!(
    title: "Printer Not Working",
    description: "The printer in the HR department is not printing.",
    ticket_type: "incident",
    status: "open",
    priority: 2,
    urgency: "medium",
    impact: "high",
    creator_id: admin_user.id,
    requester_id: teamlead_user.id,
    assignee_id: agent_user.id,
    user_id: admin_user.id,
    organization: organization,
    reported_at: Time.current,
    category: "Hardware",
    caller_name: "John",
    caller_surname: "Doe",
    caller_email: "john.doe@example.com",
    caller_phone: "123-456-7890",
    customer: "HR Department",
    source: "Phone",
    team_id: it_team.id,
    ticket_number: "TICKET-#{Time.current.to_i}"
  )

  ticket2 = Ticket.create!(
    title: "Email Access Issue",
    description: "Unable to access email account.",
    ticket_type: "service_request",
    status: "open",
    priority: 3,
    urgency: "low",
    impact: "medium",
    creator_id: teamlead_user.id,
    requester_id: agent_user.id,
    assignee_id: admin_user.id,
    user_id: teamlead_user.id,
    organization: organization,
    reported_at: Time.current,
    category: "Software",
    caller_name: "Jane",
    caller_surname: "Smith",
    caller_email: "jane.smith@example.com",
    caller_phone: "987-654-3210",
    customer: "IT Department",
    source: "Email",
    team_id: support_team.id,
    ticket_number: "TICKET-#{Time.current.to_i + 1}"
  )

  puts "Created tickets: #{ticket1.title}, #{ticket2.title}"

  # Create problems
  puts "Creating problems..."
  problem1 = Problem.create!(
    description: "Printer not working",
    ticket_id: ticket1.id,
    user_id: admin_user.id,
    creator_id: admin_user.id,
    team_id: it_team.id,
    organization_id: organization.id
  )

  problem2 = Problem.create!(
    description: "Email access issue",
    ticket_id: ticket2.id,
    user_id: teamlead_user.id,
    creator_id: teamlead_user.id,
    team_id: support_team.id,
    organization_id: organization.id
  )

  puts "Created problems: #{problem1.description}, #{problem2.description}"
else
  puts "Failed to create admin user. Other users, tickets, and problems will not be created."
end

puts "Seeding completed successfully!"