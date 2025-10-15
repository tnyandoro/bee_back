# Clear existing data
puts "Cleaning database..."
Ticket.destroy_all
Problem.destroy_all
Comment.destroy_all
Notification.destroy_all
KnowledgebaseEntry.destroy_all
SlaPolicy.destroy_all
BusinessHour.destroy_all
User.destroy_all
Team.destroy_all
Department.destroy_all
Organization.destroy_all

puts "Creating organizations..."
org = Organization.create!(
  name: "Tech Solutions Inc",
  address: "123 Tech Street, Silicon Valley",
  email: "info@techsolutions.com",
  web_address: "https://techsolutions.com",
  subdomain: "techsolutions",
  phone_number: "+1234567890"
)

puts "Creating departments..."
departments = [
  Department.create!(name: "IT Support", organization: org),
  Department.create!(name: "Network Operations", organization: org),
  Department.create!(name: "Application Support", organization: org),
  Department.create!(name: "Infrastructure", organization: org)
]

puts "Creating teams..."
teams = [
  Team.create!(name: "Service Desk", organization: org),
  Team.create!(name: "Level 1 Support", organization: org),
  Team.create!(name: "Level 2 Support", organization: org),
  Team.create!(name: "Level 3 Support", organization: org),
  Team.create!(name: "Network Team", organization: org),
  Team.create!(name: "Database Team", organization: org)
]

puts "Creating users..."

# System Admin
admin = User.create!(
  name: "System",
  last_name: "Admin",
  email: "admin@techsolutions.com",
  username: "admin",
  password: "Password123!",
  password_confirmation: "Password123!",
  role: :system_admin,
  organization: org,
  department: departments[0],
  phone_number: "+1234567891"
)

# Domain Admin
domain_admin = User.create!(
  name: "Domain",
  last_name: "Admin",
  email: "domain.admin@techsolutions.com",
  username: "domain_admin",
  password: "Password123!",
  password_confirmation: "Password123!",
  role: :domain_admin,
  organization: org,
  department: departments[0],
  phone_number: "+1234567892"
)

# General Manager
general_manager = User.create!(
  name: "General",
  last_name: "Manager",
  email: "gm@techsolutions.com",
  username: "general_manager",
  password: "Password123!",
  password_confirmation: "Password123!",
  role: :general_manager,
  organization: org,
  department: departments[0],
  phone_number: "+1234567893"
)

# Service Desk Manager
sd_manager = User.create!(
  name: "Service Desk",
  last_name: "Manager",
  email: "sd.manager@techsolutions.com",
  username: "sd_manager",
  password: "Password123!",
  password_confirmation: "Password123!",
  role: :service_desk_manager,
  organization: org,
  team: teams[0],
  department: departments[0],
  phone_number: "+1234567894"
)

# Service Desk Team Lead
sd_tl = User.create!(
  name: "Service Desk",
  last_name: "TeamLead",
  email: "sd.tl@techsolutions.com",
  username: "sd_teamlead",
  password: "Password123!",
  password_confirmation: "Password123!",
  role: :service_desk_tl,
  organization: org,
  team: teams[0],
  department: departments[0],
  phone_number: "+1234567895"
)

# Call Center Agents
2.times do |i|
  User.create!(
    name: "Call Center",
    last_name: "Agent#{i + 1}",
    email: "cc.agent#{i + 1}@techsolutions.com",
    username: "cc_agent#{i + 1}",
    password: "Password123!",
    password_confirmation: "Password123!",
    role: :call_center_agent,
    organization: org,
    team: teams[0],
    department: departments[0],
    phone_number: "+123456789#{i + 6}"
  )
end

# Service Desk Agents
3.times do |i|
  User.create!(
    name: "Service Desk",
    last_name: "Agent#{i + 1}",
    email: "sd.agent#{i + 1}@techsolutions.com",
    username: "sd_agent#{i + 1}",
    password: "Password123!",
    password_confirmation: "Password123!",
    role: :service_desk_agent,
    organization: org,
    team: teams[0],
    department: departments[0],
    phone_number: "+123456790#{i}"
  )
end

# Assignment Group Team Lead
ag_tl = User.create!(
  name: "Assignment Group",
  last_name: "TeamLead",
  email: "ag.tl@techsolutions.com",
  username: "ag_teamlead",
  password: "Password123!",
  password_confirmation: "Password123!",
  role: :assignment_group_tl,
  organization: org,
  team: teams[3],
  department: departments[2],
  phone_number: "+1234567903"
)

# Level 1-2 Assignees
4.times do |i|
  User.create!(
    name: "Level 1-2",
    last_name: "Tech#{i + 1}",
    email: "l12.tech#{i + 1}@techsolutions.com",
    username: "l12_tech#{i + 1}",
    password: "Password123!",
    password_confirmation: "Password123!",
    role: :assignee_lvl_1_2,
    organization: org,
    team: teams[1 + (i % 2)],
    department: departments[i % 3 + 1],
    phone_number: "+123456790#{i + 4}"
  )
end

# Level 3 Assignees
3.times do |i|
  User.create!(
    name: "Level 3",
    last_name: "Expert#{i + 1}",
    email: "l3.expert#{i + 1}@techsolutions.com",
    username: "l3_expert#{i + 1}",
    password: "Password123!",
    password_confirmation: "Password123!",
    role: :assignee_lvl_3,
    organization: org,
    team: teams[3 + i],
    department: departments[i + 1],
    phone_number: "+123456791#{i}"
  )
end

# Incident Manager
incident_mgr = User.create!(
  name: "Incident",
  last_name: "Manager",
  email: "incident.mgr@techsolutions.com",
  username: "incident_manager",
  password: "Password123!",
  password_confirmation: "Password123!",
  role: :incident_manager,
  organization: org,
  department: departments[0],
  phone_number: "+1234567913"
)

# Problem Manager
problem_mgr = User.create!(
  name: "Problem",
  last_name: "Manager",
  email: "problem.mgr@techsolutions.com",
  username: "problem_manager",
  password: "Password123!",
  password_confirmation: "Password123!",
  role: :problem_manager,
  organization: org,
  department: departments[0],
  phone_number: "+1234567914"
)

# Change Manager
change_mgr = User.create!(
  name: "Change",
  last_name: "Manager",
  email: "change.mgr@techsolutions.com",
  username: "change_manager",
  password: "Password123!",
  password_confirmation: "Password123!",
  role: :change_manager,
  organization: org,
  department: departments[0],
  phone_number: "+1234567915"
)

# Department Manager
dept_mgr = User.create!(
  name: "Department",
  last_name: "Manager",
  email: "dept.mgr@techsolutions.com",
  username: "dept_manager",
  password: "Password123!",
  password_confirmation: "Password123!",
  role: :department_manager,
  organization: org,
  department: departments[1],
  phone_number: "+1234567916"
)

puts "Creating SLA Policies..."
sla_policies = [
  SlaPolicy.create!(
    organization: org,
    priority: 0, # Critical
    response_time: 15, # 15 minutes
    resolution_time: 240, # 4 hours
    description: "Critical priority - immediate response required"
  ),
  SlaPolicy.create!(
    organization: org,
    priority: 1, # High
    response_time: 60, # 1 hour
    resolution_time: 480, # 8 hours
    description: "High priority - quick response needed"
  ),
  SlaPolicy.create!(
    organization: org,
    priority: 2, # Medium
    response_time: 240, # 4 hours
    resolution_time: 1440, # 24 hours
    description: "Medium priority - standard response time"
  ),
  SlaPolicy.create!(
    organization: org,
    priority: 3, # Low
    response_time: 480, # 8 hours
    resolution_time: 2880, # 48 hours
    description: "Low priority - extended response time"
  )
]

puts "Creating Business Hours..."
# Monday to Friday, 9 AM to 5 PM
(1..5).each do |day|
  BusinessHour.create!(
    organization: org,
    day_of_week: day,
    start_time: "09:00",
    end_time: "17:00",
    active: true
  )
end

puts "Creating Knowledge Base Entries..."
[
  {
    issue: "Password Reset",
    description: "User unable to login due to forgotten password",
    troubleshooting_steps: "1. Verify user identity\n2. Check account status\n3. Verify email address",
    assigned_group: "Service Desk",
    resolution_steps: "1. Navigate to password reset tool\n2. Enter user email\n3. Send reset link\n4. Confirm user received email"
  },
  {
    issue: "Email Not Working",
    description: "User cannot send or receive emails",
    troubleshooting_steps: "1. Check internet connection\n2. Verify email credentials\n3. Check server status\n4. Review email client settings",
    assigned_group: "Level 1 Support",
    resolution_steps: "1. Test connection\n2. Reconfigure email client\n3. Clear cache\n4. Restart email application"
  },
  {
    issue: "VPN Connection Issues",
    description: "Unable to connect to corporate VPN",
    troubleshooting_steps: "1. Check internet connectivity\n2. Verify VPN credentials\n3. Check VPN client version\n4. Review firewall settings",
    assigned_group: "Network Team",
    resolution_steps: "1. Update VPN client\n2. Reconfigure VPN settings\n3. Check certificate validity\n4. Contact network team if issue persists"
  },
  {
    issue: "Printer Not Responding",
    description: "Network printer not printing documents",
    troubleshooting_steps: "1. Check printer power\n2. Verify network connection\n3. Check print queue\n4. Restart print spooler",
    assigned_group: "Level 1 Support",
    resolution_steps: "1. Clear print queue\n2. Restart printer\n3. Reinstall printer drivers\n4. Test print"
  },
  {
    issue: "Software Installation Request",
    description: "User needs new software installed",
    troubleshooting_steps: "1. Verify software license availability\n2. Check system requirements\n3. Confirm approval from manager",
    assigned_group: "Level 2 Support",
    resolution_steps: "1. Download approved software\n2. Run installation\n3. Configure software\n4. Test functionality"
  }
].each do |kb_entry|
  KnowledgebaseEntry.create!(
    organization: org,
    issue: kb_entry[:issue],
    description: kb_entry[:description],
    troubleshooting_steps: kb_entry[:troubleshooting_steps],
    assigned_group: kb_entry[:assigned_group],
    resolution_steps: kb_entry[:resolution_steps]
  )
end

puts "Creating sample tickets..."
service_desk_agents = User.where(role: [:service_desk_agent, :service_desk_tl]).to_a

10.times do |i|
  creator = service_desk_agents.sample
  
  # Pick a random team and then pick an assignee from that team
  selected_team = teams.sample
  team_assignees = User.where(team: selected_team, role: [:assignee_lvl_1_2, :assignee_lvl_3]).to_a
  
  # If no assignees in the selected team, pick from all assignees and use their team
  if team_assignees.empty?
    assignee = User.where(role: [:assignee_lvl_1_2, :assignee_lvl_3]).sample
    selected_team = assignee&.team || teams[1] # Fallback to Level 1 Support team
  else
    assignee = team_assignees.sample
  end
  
  ticket = Ticket.create!(
    title: "Issue #{i + 1}: #{['Password Reset', 'Email Problem', 'VPN Access', 'Software Install', 'Printer Issue'].sample}",
    description: "Detailed description of the issue that needs to be resolved.",
    ticket_number: "INC#{Time.now.year}#{sprintf('%06d', i + 1)}",
    ticket_type: "Incident",
    priority: rand(0..3),
    urgency: rand(0..2),
    impact: rand(0..2),
    status: [0, 1, 2, 3, 6].sample, # open, in_progress, pending, resolved, new
    category: ["Query", "Complaint", "Compliment", "Other"].sample,
    source: ["Email", "Phone", "Portal", "Walk-in"].sample,
    caller_name: "John",
    caller_surname: "Doe#{i + 1}",
    caller_email: "john.doe#{i + 1}@example.com",
    caller_phone: "+123456789#{sprintf('%02d', i)}",
    customer: "Customer #{i + 1}",
    organization: org,
    team: selected_team,
    department_id: departments.sample.id,
    creator: creator,
    assignee: assignee,
    requester: creator,
    reported_at: Time.current - rand(1..10).days,
    sla_policy: sla_policies.sample
  )
  
  # Add some comments
  rand(1..3).times do |j|
    Comment.create!(
      content: "Comment #{j + 1} on ticket #{ticket.ticket_number}",
      user: [creator, assignee].sample,
      ticket: ticket
    )
  end
end

puts "Seed data created successfully!"
puts "\n=== Login Credentials ==="
puts "System Admin:"
puts "  Email: admin@techsolutions.com"
puts "  Password: Password123!"
puts "\nDomain Admin:"
puts "  Email: domain.admin@techsolutions.com"
puts "  Password: Password123!"
puts "\nService Desk Agent:"
puts "  Email: sd.agent1@techsolutions.com"
puts "  Password: Password123!"
puts "\nAll users have the same password: Password123!"
puts "========================\n"