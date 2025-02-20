# Services for Mobile and Web Frontend

This document outlines the API services required for mobile and web frontends to interact with the multi-tenant ITSM system built in Ruby on Rails. The services are categorized by feature area and based on the existing `routes.rb`, database schema, and functionality discussed. All endpoints assume subdomain-based routing (e.g., `example5.lvh.me`) for organization scoping and token-based authentication using `Authorization: Bearer <token>`.

## 1. Authentication Services

These services handle user login, logout, and registration.

| **Service**                | **HTTP Method** | **Endpoint**                           | **Description**                                                                 | **Request Payload**                  | **Response**                     |
|----------------------------|-----------------|----------------------------------------|--------------------------------------------------------------------------------|--------------------------------------|----------------------------------|
| Login                      | POST            | `/api/v1/login`                        | Authenticate a user and return an auth token. Scoped by subdomain (e.g., `example5.lvh.me`). | `{ "email": "user@example.com", "password": "pass" }` | `{ "auth_token": "...", "user": { ... } }` |
| Logout                     | DELETE          | `/api/v1/logout`                       | Invalidate the user’s auth token. Requires `Authorization: Bearer <token>` header. | None                                 | `{ "message": "Logout successful" }` |
| Register Organization      | POST            | `/api/v1/register`                     | Create a new organization (outside subdomain scope).                          | `{ "organization": { "name": "...", "subdomain": "..." }, "admin": { "email": "...", "password": "..." } }` | `{ "organization": { ... }, "admin": { ... } }` |
| Register Admin             | POST            | `/api/v1/organizations/:subdomain/register_admin` | Register an admin for an existing organization.              | `{ "admin": { "name": "...", "email": "...", "password": "..." } }` | `{ "admin": { ... } }` |

**Notes:**
- Frontends must store the `auth_token` locally and include it in the `Authorization` header for authenticated requests.
- Login uses the subdomain (e.g., `http://example5.lvh.me:3000/api/v1/login`).

## 2. Organization Services

These manage organization-level data, primarily for admin users.

| **Service**                | **HTTP Method** | **Endpoint**                           | **Description**                                                                 | **Request Payload**                  | **Response**                     |
|----------------------------|-----------------|----------------------------------------|--------------------------------------------------------------------------------|--------------------------------------|----------------------------------|
| List Organizations         | GET             | `/api/v1/organizations`                | Retrieve all organizations (admin-only, scoped by subdomain?).                | None                                 | `[ { "id": 35, "subdomain": "example5", "name": "..." }, ... ]` |
| Show Organization          | GET             | `/api/v1/organizations/:subdomain`     | Get details of the current organization (based on subdomain).                 | None                                 | `{ "id": 35, "subdomain": "example5", "name": "..." }` |
| Update Organization        | PATCH/PUT       | `/api/v1/organizations/:subdomain`     | Update organization details (admin-only).                                     | `{ "organization": { "name": "...", "address": "..." } }` | `{ "id": 35, "subdomain": "example5", "name": "..." }` |
| Delete Organization        | DELETE          | `/api/v1/organizations/:subdomain`     | Delete the organization (admin-only).                                         | None                                 | (204 No Content)                |

**Notes:**
- Subdomain is part of the URL (e.g., `http://example5.lvh.me:3000/api/v1/organizations/example5`).

## 3. User Services

These manage users within an organization.

| **Service**                | **HTTP Method** | **Endpoint**                           | **Description**                                                                 | **Request Payload**                  | **Response**                     |
|----------------------------|-----------------|----------------------------------------|--------------------------------------------------------------------------------|--------------------------------------|----------------------------------|
| List Users                 | GET             | `/api/v1/organizations/:subdomain/users` | Get all users in the organization.                                          | None                                 | `[ { "id": 305, "email": "admin35@example.com", "role": "admin" }, ... ]` |
| Show User                  | GET             | `/api/v1/users/:id`                    | Get details of a specific user (global scope).                                | None                                 | `{ "id": 305, "email": "...", "role": "..." }` |
| Create User                | POST            | `/api/v1/organizations/:subdomain/users` | Create a new user in the organization (admin-only).                        | `{ "user": { "name": "...", "email": "...", "password": "...", "role": "agent" } }` | `{ "id": 306, "email": "..." }` |
| Update User                | PATCH/PUT       | `/api/v1/users/:id`                    | Update a user’s details (admin or self).                                      | `{ "user": { "name": "...", "phone_number": "..." } }` | `{ "id": 305, "email": "..." }` |
| Delete User                | DELETE          | `/api/v1/users/:id`                    | Delete a user (admin-only).                                                   | None                                 | (204 No Content)                |
| List User Tickets          | GET             | `/api/v1/users/:id/tickets`            | Get tickets associated with a user (e.g., created or assigned).               | None                                 | `[ { "id": 1, "title": "..." }, ... ]` |

**Notes:**
- Use organization-scoped endpoints (`/organizations/:subdomain/users`) for consistency.

## 4. Ticket Services

Core ITSM functionality for managing tickets.

| **Service**                | **HTTP Method** | **Endpoint**                           | **Description**                                                                 | **Request Payload**                  | **Response**                     |
|----------------------------|-----------------|----------------------------------------|--------------------------------------------------------------------------------|--------------------------------------|----------------------------------|
| List Tickets               | GET             | `/api/v1/organizations/:subdomain/tickets` | Get all tickets in the organization.                                       | None                                 | `[ { "id": 1, "title": "Issue", "status": "open" }, ... ]` |
| Show Ticket                | GET             | `/api/v1/tickets/:id`                  | Get details of a specific ticket.                                             | None                                 | `{ "id": 1, "title": "...", "description": "..." }` |
| Create Ticket              | POST            | `/api/v1/organizations/:subdomain/tickets` | Create a new ticket in the organization.                                  | `{ "ticket": { "title": "...", "description": "...", "priority": 1 } }` | `{ "id": 2, "title": "..." }` |
| Update Ticket              | PATCH/PUT       | `/api/v1/tickets/:id`                  | Update a ticket’s details.                                                    | `{ "ticket": { "status": "closed", "assignee_id": 305 } }` | `{ "id": 1, "title": "..." }` |
| Delete Ticket              | DELETE          | `/api/v1/tickets/:id`                  | Delete a ticket.                                                              | None                                 | (204 No Content)                |
| Assign Ticket to User      | POST            | `/api/v1/tickets/:id/assign_to_user`   | Assign a ticket to a user.                                                    | `{ "user_id": 305 }`                 | `{ "id": 1, "assignee_id": 305 }` |
| Escalate to Problem        | POST            | `/api/v1/tickets/:id/escalate_to_problem` | Escalate a ticket to a problem record.                                     | None                                 | `{ "problem_id": 1 }`           |

**Notes:**
- Add filtering (e.g., `?status=open`) for better usability.

## 5. Problem Services

For managing problem records linked to tickets.

| **Service**                | **HTTP Method** | **Endpoint**                           | **Description**                                                                 | **Request Payload**                  | **Response**                     |
|----------------------------|-----------------|----------------------------------------|--------------------------------------------------------------------------------|--------------------------------------|----------------------------------|
| List Problems              | GET             | `/api/v1/organizations/:subdomain/problems` | Get all problems in the organization.                                      | None                                 | `[ { "id": 1, "description": "..." }, ... ]` |
| Show Problem               | GET             | `/api/v1/problems/:id`                 | Get details of a specific problem.                                            | None                                 | `{ "id": 1, "description": "..." }` |
| Create Problem             | POST            | `/api/v1/organizations/:subdomain/problems` | Create a new problem (manual or via escalation).                          | `{ "problem": { "description": "...", "ticket_id": 1 } }` | `{ "id": 2, "description": "..." }` |
| Update Problem             | PATCH/PUT       | `/api/v1/problems/:id`                 | Update a problem’s details.                                                   | `{ "problem": { "description": "..." } }` | `{ "id": 1, "description": "..." }` |
| Delete Problem             | DELETE          | `/api/v1/problems/:id`                 | Delete a problem.                                                             | None                                 | (204 No Content)                |

**Notes:**
- Problems link to tickets via `ticket_id`.

## 6. Team Services

For managing teams within an organization.

| **Service**                | **HTTP Method** | **Endpoint**                           | **Description**                                                                 | **Request Payload**                  | **Response**                     |
|----------------------------|-----------------|----------------------------------------|--------------------------------------------------------------------------------|--------------------------------------|----------------------------------|
| List Teams                 | GET             | `/api/v1/organizations/:subdomain/teams` | Get all teams in the organization.                                          | None                                 | `[ { "id": 1, "name": "Support Team" }, ... ]` |
| Show Team                  | GET             | `/api/v1/teams/:id`                    | Get details of a specific team.                                               | None                                 | `{ "id": 1, "name": "..." }`    |
| Create Team                | POST            | `/api/v1/organizations/:subdomain/teams` | Create a new team in the organization.                                     | `{ "team": { "name": "Support Team" } }` | `{ "id": 2, "name": "..." }` |
| Update Team                | PATCH/PUT       | `/api/v1/teams/:id`                    | Update a team’s details.                                                      | `{ "team": { "name": "..." } }`      | `{ "id": 1, "name": "..." }`    |
| Delete Team                | DELETE          | `/api/v1/teams/:id`                    | Delete a team.                                                                | None                                 | (204 No Content)                |

**Notes:**
- Teams link to users via `team_id`.

## 7. Notification Services

For user notifications.

| **Service**                | **HTTP Method** | **Endpoint**                           | **Description**                                                                 | **Request Payload**                  | **Response**                     |
|----------------------------|-----------------|----------------------------------------|--------------------------------------------------------------------------------|--------------------------------------|----------------------------------|
| List Notifications         | GET             | `/api/v1/organizations/:subdomain/notifications` | Get all notifications for the user in the organization.                  | None                                 | `[ { "id": 1, "message": "...", "read": false }, ... ]` |
| Mark Notification as Read  | PATCH           | `/api/v1/notifications/:id/mark_as_read` | Mark a notification as read.                                              | None                                 | `{ "id": 1, "read": true }`     |

**Notes:**
- Mobile apps might integrate push notifications (e.g., Firebase).

## Additional Considerations

- **Pagination:** Add `?page=1&per_page=20` to list endpoints for large datasets.
- **Filtering/Search:** Add query params like `?status=open` or `?q=keyword`.
- **Comments:** Consider adding `/tickets/:id/comments` endpoints.
- **Error Handling:** Return consistent error formats (e.g., `{ "error": "message" }`).
- **CORS:** Configure CORS if frontends are hosted separately.

## Frontend Integration

- **Mobile (React Native, Flutter):**
  - Use HTTP clients (Axios, Dio).
  - Store `auth_token` securely (Keychain, Secure Storage).
  - Handle subdomains dynamically.

- **Web (React, Vue):**
  - Use fetch/Axios with subdomain in the base URL.
  - Store `auth_token` in local storage/cookies.
  - Implement organization-specific routing.