# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#

# Clear existing data
puts "Clearing existing data..."
Ticket.destroy_all
User.destroy_all
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
  organization: organization
)

agent_user = User.create!(
  name: "Agent User",
  email: "agent@example.com",
  password: "password",
  role: :agent,
  department: "Support",
  position: "Support Agent",
  organization: organization
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
  ticket_type: "incident", # Use string values for ticket_type
  status: "open",          # Use string values for status
  priority: 2,             # Use integer value for enum priority (:high => 2)
  urgency: "Medium",       # Use string values for enum urgency
  impact: "High",          # Use string values for enum impact
  creator: admin_user,
  organization: organization,
  requester: teamlead_user,
  assignee: agent_user
)

Ticket.create!(
  title: "Email Access Issue",
  description: "Unable to access email account.",
  ticket_type: "service_request",
  status: "pending",
  priority: 3,             # Use integer value for enum priority (:medium => 3)
  urgency: "Low",          # Use string values for enum urgency
  impact: "Medium",        # Use string values for enum impact
  creator: teamlead_user,
  organization: organization,
  requester: agent_user,
  assignee: admin_user
)

puts "Seeding completed successfully!"
