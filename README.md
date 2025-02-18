# README

# IT Service Management (ITSM) System Overview

This document provides a detailed overview of the IT Service Management (ITSM) system, focusing on its architecture, functionality, and operational flow. The system is designed as a multi-tenant incident reporting and management platform that leverages Service Level Agreements (SLAs) to ensure timely resolution of incidents. If an incident breaches its SLA, notifications are sent to team leads, and the incident can be escalated to a problem for further investigation.


## 1. Database Schema Overview

The ITSM system's database schema is defined using Rails migrations and ActiveRecord. Below is a breakdown of the key tables and their relationships:

### 1.1 Organizations
- **Description**: Represents each tenant in the multi-tenant system.
- **Fields**:
  - `name`: Name of the organization.
  - `address`: Physical address of the organization.
  - `email`: Contact email for the organization.
  - `web_address`: Website URL of the organization.
  - `subdomain`: Unique subdomain for the organization's instance.
  - `created_at`, `updated_at`: Timestamps for record creation and updates.
- **Indexes**:
  - `subdomain` (unique): Ensures each organization has a unique subdomain.

### 1.2 Users
- **Description**: Represents individuals within an organization who interact with the system.
- **Fields**:
  - `name`, `email`, `password_digest`: Basic user information.
  - `role`: Defines the user's role (e.g., admin, technician, manager).
  - `organization_id`: Links the user to their organization.
  - `department`, `position`: Additional details about the user's role within the organization.
  - `team_id`: Associates the user with a specific team.
  - `created_at`, `updated_at`: Timestamps for record creation and updates.
- **Indexes**:
  - `email` (unique): Ensures each user has a unique email.
  - `organization_id`: Facilitates querying users by organization.

### 1.3 Teams
- **Description**: Represents groups of users working together within an organization.
- **Fields**:
  - `name`: Name of the team.
  - `organization_id`: Links the team to its organization.
  - `created_at`, `updated_at`: Timestamps for record creation and updates.
- **Indexes**:
  - `organization_id`: Facilitates querying teams by organization.

### 1.4 Tickets
- **Description**: Represents incidents or service requests reported by users.
- **Fields**:
  - `title`, `description`: Details of the ticket.
  - `priority`, `urgency`, `impact`: Metrics to determine the severity of the issue.
  - `ticket_number`, `ticket_type`: Unique identifier and type of the ticket.
  - `assignee_id`, `team_id`, `requester_id`: Identifies the responsible parties.
  - `reported_at`: Timestamp for when the ticket was created.
  - `category`, `caller_name`, `caller_surname`, `caller_email`, `caller_phone`: Caller information.
  - `customer`, `source`: Details about the customer and how the ticket was submitted.
  - `creator_id`, `user_id`: Identifies who created the ticket and the user associated with it.
  - `status`: Current status of the ticket (e.g., open, in progress, resolved).
  - `created_at`, `updated_at`: Timestamps for record creation and updates.
- **Indexes**:
  - `ticket_number` (unique): Ensures each ticket has a unique number.
  - `organization_id`, `user_id`: Facilitates querying tickets by organization and user.

### 1.5 Problems
- **Description**: Represents issues that may arise from unresolved or recurring incidents.
- **Fields**:
  - `description`: Detailed explanation of the problem.
  - `ticket_id`: Links the problem to its originating ticket.
  - `user_id`, `organization_id`: Identifies the user and organization involved.
  - `created_at`, `updated_at`: Timestamps for record creation and updates.
- **Indexes**:
  - `ticket_id`: Facilitates querying problems by ticket.
  - `user_id`: Facilitates querying problems by user.

### 1.6 Notifications
- **Description**: Represents alerts sent to users regarding incidents or problems.
- **Fields**:
  - `user_id`, `organization_id`: Identifies the recipient and their organization.
  - `message`: Content of the notification.
  - `read`: Indicates whether the notification has been read.
  - `created_at`, `updated_at`: Timestamps for record creation and updates.
- **Indexes**:
  - `organization_id`, `user_id`: Facilitates querying notifications by organization and user.

---

## 2. Functional Workflow

### 2.1 Incident Reporting
1. **Ticket Creation**:
   - A user submits a ticket via the ITSM portal, providing details such as title, description, urgency, impact, and caller information.
   - The system assigns a unique `ticket_number` and categorizes the ticket based on predefined rules.
   - The ticket is assigned to a team or individual based on the `category` and `priority`.

2. **Assignment and Notification**:
   - The ticket is assigned to a `team_id` or `assignee_id`.
   - Notifications are sent to the assignee and team lead via the `notifications` table.

3. **SLA Tracking**:
   - The system monitors the ticket against its SLA based on urgency and priority.
   - If the SLA is breached, a notification is triggered and sent to the team lead.

### 2.2 Problem Escalation
1. **Identification**:
   - If a ticket remains unresolved beyond its SLA or exhibits recurring patterns, it is flagged for escalation.
   - A `problem` record is created, linked to the original ticket via `ticket_id`.

2. **Investigation**:
   - The problem is assigned to a senior team or specialist for deeper analysis.
   - Updates are logged in the `problems` table, including any findings or resolutions.

3. **Resolution**:
   - Once the root cause is identified and addressed, the problem is marked as resolved.
   - Any related tickets are updated accordingly.

---

## 3. Key Features

### 3.1 Multi-Tenancy
- Each organization operates in its own isolated environment, identified by a unique `subdomain`.
- Data isolation is enforced through foreign keys linking all entities (`users`, `teams`, `tickets`) to an `organization_id`.

### 3.2 SLA-Based Alerts
- SLAs are defined at the organizational level and applied to tickets based on their urgency and priority.
- Breaches trigger automated notifications to relevant stakeholders, ensuring timely intervention.

### 3.3 Role-Based Access Control
- User roles (e.g., admin, technician, manager) dictate access levels and permissions.
- For example, only managers can escalate tickets to problems.

### 3.4 Team Collaboration
- Teams are organized within organizations, allowing for efficient assignment and tracking of tickets.
- Team leads receive notifications for critical incidents and problem escalations.

---

## 4. Use Cases

### 4.1 Incident Management
- **Scenario**: A user reports a printer malfunction.
- **Steps**:
  1. A ticket is created with details about the issue.
  2. The ticket is assigned to the IT support team.
  3. If the issue is not resolved within the SLA, a notification is sent to the team lead.
  4. If the issue persists, it is escalated to a problem for further investigation.

### 4.2 Problem Resolution
- **Scenario**: Recurring network outages are reported.
- **Steps**:
  1. Multiple tickets are flagged for escalation due to recurring patterns.
  2. A problem record is created, detailing the potential root cause.
  3. A specialist investigates and resolves the underlying issue.
  4. All related tickets are updated with the resolution.

---

## 5. Future Enhancements

1. **Automated Root Cause Analysis**:
   - Integrate AI/ML models to predict and identify root causes of recurring issues.

2. **Advanced Reporting**:
   - Provide dashboards for real-time monitoring of SLA compliance and team performance.

3. **Mobile App Integration**:
   - Develop a mobile app for users to submit tickets and receive notifications on-the-go.

4. **Third-Party Integrations**:
   - Enable integrations with external tools like Slack, Jira, and email systems for seamless communication.

# IT Service Management (ITSM) Backend Setup Guide

This README provides step-by-step instructions for setting up the ITSM backend application, which is built using Ruby on Rails with a PostgreSQL database.

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Clone the Repository](#2-clone-the-repository)
3. [Set Up the Environment](#3-set-up-the-environment)
4. [Set Up the Database](#4-set-up-the-database)
5. [Run the Application](#5-run-the-application)
6. [Run Tests](#6-run-tests)
7. [Additional Configuration](#7-additional-configuration)
8. [Deployment](#8-deployment)
9. [Troubleshooting](#9-troubleshooting)
10. [Contributing](#10-contributing)

---
# Ruby on Rails Application Setup Guide

This guide provides step-by-step instructions to clone, set up, and run a Ruby on Rails application with a PostgreSQL database on your local machine.

---

## Prerequisites

Before starting, ensure you have the following installed on your machine:

1. **Ruby**: Version 3.x or higher (check with `ruby -v`).
2. **Rails**: Version 7.x or higher (check with `rails -v`).
3. **PostgreSQL**: Installed and running (check with `psql --version`).
4. **Git**: Installed (check with `git --version`).
5. **Node.js** and **Yarn**: Required for asset compilation (check with `node -v` and `yarn -v`).

If any of these are missing, follow the installation instructions below:

- **Ruby**: Use [rbenv](https://github.com/rbenv/rbenv) or [RVM](https://rvm.io/).
- **Rails**: Install with `gem install rails`.
- **PostgreSQL**: Download from [postgresql.org](https://www.postgresql.org/download/).
- **Node.js**: Download from [nodejs.org](https://nodejs.org/).
- **Yarn**: Install with `npm install -g yarn`.

---

## Step 1: Clone the Repository

1. Open your terminal.
2. Navigate to the directory where you want to clone the project.
3. Clone the repository:
   ```bash
   git clone https://github.com/your-username/your-repo-name.git
   ```
4. Navigate into the project directory:
   ```bash
   cd your-repo-name
   ```

---

## Step 2: Install Dependencies

1. Install Ruby gems:
   ```bash
   bundle install
   ```
2. Install JavaScript dependencies:
   ```bash
   yarn install
   ```

---

## Step 3: Set Up the Database

1. Ensure PostgreSQL is running on your machine.
2. Update the `config/database.yml` file with your PostgreSQL credentials:
   ```yaml
   default: &default
     adapter: postgresql
     encoding: unicode
     pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
     username: your_postgres_username
     password: your_postgres_password
     host: localhost
     port: 5432

   development:
     <<: *default
     database: your_app_name_development

   test:
     <<: *default
     database: your_app_name_test
   ```
3. Create the databases:
   ```bash
   rails db:create
   ```
4. Run migrations:
   ```bash
   rails db:migrate
   ```
5. (Optional) Seed the database with sample data:
   ```bash
   rails db:seed
   ```

---

## Step 4: Run the Application

1. Start the Rails server:
   ```bash
   rails server
   ```
2. Open your browser and navigate to:
   ```
   http://localhost:3000
   ```

---

## Step 5: Running Tests

To run the test suite, use:
```bash
rails test
```

---

## Troubleshooting

### Common Issues

1. **Database Connection Errors**:
   - Ensure PostgreSQL is running.
   - Verify credentials in `config/database.yml`.

2. **Missing Dependencies**:
   - Run `bundle install` and `yarn install` again.

3. **Port Conflicts**:
   - Use a different port for the Rails server:
     ```bash
     rails server -p 3001
     ```

4. **Asset Compilation Errors**:
   - Ensure Node.js and Yarn are installed.
   - Run `yarn install` and `rails assets:precompile`.

---

## Additional Resources

- [Ruby on Rails Guides](https://guides.rubyonrails.org/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Rbenv Documentation](https://github.com/rbenv/rbenv)
- [Yarn Documentation](https://yarnpkg.com/getting-started)

