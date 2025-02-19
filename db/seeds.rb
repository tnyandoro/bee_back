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
  subdomain: "example" # Ensure subdomain is unique
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
  password: "password", # Default password for development
  role: :admin,
  department: "Management",
  position: "Admin",
  organization: organization # Ensure the admin user is assigned to the organization
)

puts "Created admin user: #{admin_user.email}"

# Only the admin can create other users
if admin_user.persisted?
  puts "Creating other users..."
  roles = [
    { name: "Teamlead User", email: "teamlead@example.com", role: :teamlead, team: it_team },
    { name: "Agent User", email: "agent@example.com", role: :agent, team: support_team },
    { name: "Viewer User", email: "viewer@example.com", role: :viewer }
  ]

  roles.each do |user_data|
    User.create!(
      name: user_data[:name],
      email: user_data[:email],
      password: "password", # Default password for development
      role: user_data[:role],
      organization: organization,
      team: user_data[:team] # Assign to the appropriate team
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
    urgency: "Medium",
    impact: "High",
    creator_id: admin_user.id, # Use creator_id
    requester_id: teamlead_user.id, # Use requester_id
    assignee_id: agent_user.id, # Use assignee_id
    user_id: admin_user.id, # Use user_id
    organization: organization,
    reported_at: Time.current,
    category: "Hardware",
    caller_name: "John",
    caller_surname: "Doe",
    caller_email: "john.doe@example.com",
    caller_phone: "123-456-7890",
    customer: "HR Department",
    source: "Phone",
    team: it_team,
    ticket_number: "TICKET-#{Time.current.to_i}" # Add unique ticket_number
  )

  ticket2 = Ticket.create!(
    title: "Email Access Issue",
    description: "Unable to access email account.",
    ticket_type: "service_request",
    status: "open",
    priority: 3,
    urgency: "Low",
    impact: "Medium",
    creator_id: teamlead_user.id, # Use creator_id
    requester_id: agent_user.id, # Use requester_id
    assignee_id: admin_user.id, # Use assignee_id
    user_id: teamlead_user.id, # Use user_id
    organization: organization,
    reported_at: Time.current,
    category: "Software",
    caller_name: "Jane",
    caller_surname: "Smith",
    caller_email: "jane.smith@example.com",
    caller_phone: "987-654-3210",
    customer: "IT Department",
    source: "Email",
    team: support_team,
    ticket_number: "TICKET-#{Time.current.to_i + 1}" # Add unique ticket_number
  )

  puts "Created tickets: #{ticket1.title}, #{ticket2.title}"

  # Create problems
  puts "Creating problems..."
  problem1 = Problem.create!(
    description: "Printer not working",
    ticket: ticket1, # Assign the ticket
    creator: admin_user, # Use creator association
    user: admin_user, # Assign the user who will resolve the problem (if applicable)
    team: it_team, # Optional: assign to the team
    organization_id: organization.id # Assign organization_id explicitly
  )

  problem2 = Problem.create!(
    description: "Email access issue",
    ticket: ticket2, # Assign the ticket
    creator: teamlead_user, # Use creator association
    user: teamlead_user, # Assign the user who will resolve the problem (if applicable)
    team: support_team, # Optional: assign to the team
    organization_id: organization.id # Assign organization_id explicitly
  )

  puts "Created problems: #{problem1.description}, #{problem2.description}"
else
  puts "Failed to create admin user. Other users, tickets, and problems will not be created."
end

puts "Seeding completed successfully!"
