# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# db/seeds.rb
organization = Organization.create!(
  name: "Example Org",
  address: "123 Main St",
  email: "info@example.com",
  web_address: "https://example.com"
  # Do not explicitly set `subdomain` if you want it to be generated automatically
)

User.create!(
  name: "Admin User",
  email: "admin@example.com",
  password: "password",
  role: :admin,
  organization: organization
)

User.create!(
  name: "Teamlead User",
  email: "teamlead@example.com",
  password: "password",
  role: :teamlead,
  organization: organization
)

User.create!(
  name: "Agent User",
  email: "agent@example.com",
  password: "password",
  role: :agent,
  organization: organization
)

User.create!(
  name: "Viewer User",
  email: "viewer@example.com",
  password: "password",
  role: :viewer,
  organization: organization
)