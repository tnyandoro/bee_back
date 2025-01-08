# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#

# Clear existing data
puts "Clearing existing data..."
Ticket.destroy_all
User.destroy_all
Team.destroy_all
Organization.destroy_all

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

super_user = User.create!(
  name: "Super User",
  email: "super@example.com",
  password: "password",
  role: :super_user,
  department: "Management",
  position: "Super User",
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
  team: it_team
)

agent_user = User.create!(
  name: "Agent User",
  email: "agent@example.com",
  password: "password",
  role: :agent,
  department: "Support",
  position: "Support Agent",
  organization: organization,
  team: support_team
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
Ticket.create!(
  title: "Printer Not Working",
  description: "The printer in the HR department is not printing.",
  ticket_type: "incident",
  status: "open",
  priority: 2,
  urgency: "Medium",
  impact: "High",
  creator: admin_user,
  organization: organization,
  requester: teamlead_user,
  assignee: agent_user,
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

Ticket.create!(
  title: "Email Access Issue",
  description: "Unable to access email account.",
  ticket_type: "service_request",
  status: "pending",
  priority: 3,
  urgency: "Low",
  impact: "Medium",
  creator: teamlead_user,
  organization: organization,
  requester: agent_user,
  assignee: admin_user,
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

puts "Seeding completed successfully!"
