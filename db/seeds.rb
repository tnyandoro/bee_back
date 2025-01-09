# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Clear existing data
puts "Clearing existing data..."
Ticket.destroy_all
User.destroy_all
Team.destroy_all
Organization.destroy_all
Problem.destroy_all # Clear existing problems

# Create an organization
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
it_team = Team.create!(name: "IT Team", organization: organization)
support_team = Team.create!(name: "Support Team", organization: organization)

# Create users
puts "Creating users..."
admin_user = User.create!(
  name: "Admin User",
  email: "admin@example.com",
  password: "password",
  role: :admin,
  department: "Management",
  position: "Admin",
  organization: organization
)

teamlead_user = User.create!(
  name: "Teamlead User",
  email: "teamlead@example.com",
  password: "password",
  role: :teamlead,
  department: "IT",
  position: "Team Lead",
  organization: organization,
  team: it_team # Assign to IT Team
)

agent_user = User.create!(
  name: "Agent User",
  email: "agent@example.com",
  password: "password",
  role: :agent,
  department: "Support",
  position: "Support Agent",
  organization: organization,
  team: support_team # Assign to Support Team
)

viewer_user = User.create!(
  name: "Viewer User",
  email: "viewer@example.com",
  password: "password",
  role: :viewer,
  department: "Operations",
  position: "Viewer",
  organization: organization
)

# Create tickets
puts "Creating tickets..."
printer_ticket = Ticket.create!(
  title: "Printer Not Working",
  description: "The printer in the HR department is not printing.",
  ticket_type: "incident",
  status: "open",
  priority: 2,
  urgency: "Medium",
  impact: "High",
  creator: admin_user, # Set the creator
  organization: organization,
  requester: teamlead_user, # Set the requester
  assignee: agent_user, # Set the assignee
  team: it_team,
  reported_at: Time.current,
  category: "Hardware",
  caller_name: "John",
  caller_surname: "Doe",
  caller_email: "john.doe@example.com",
  caller_phone: "123-456-7890",
  customer: "HR Department",
  source: "Phone"
)

email_ticket = Ticket.create!(
  title: "Email Access Issue",
  description: "Unable to access email account.",
  ticket_type: "service_request",
  status: "pending",
  priority: 3,
  urgency: "Low",
  impact: "Medium",
  creator: teamlead_user, # Set the creator
  organization: organization,
  requester: agent_user, # Set the requester
  assignee: admin_user, # Set the assignee
  team: support_team,
  reported_at: Time.current,
  category: "Software",
  caller_name: "Jane",
  caller_surname: "Smith",
  caller_email: "jane.smith@example.com",
  caller_phone: "987-654-3210",
  customer: "IT Department",
  source: "Email"
)

# Escalate the "Printer Not Working" ticket to a problem
puts "Escalating ticket to a problem..."
problem = Problem.create!(
  description: printer_ticket.description,
  organization: printer_ticket.organization,
  team: printer_ticket.team,
  creator: teamlead_user, # Team lead escalates the ticket
  reported_at: Time.current
)

# Link the ticket to the problem
printer_ticket.update!(problem: problem)

puts "Seeding completed successfully!"
