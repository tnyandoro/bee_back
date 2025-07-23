# Rails API Documentation

## Base Information

- **Production URL**: `https://itsm-api.onrender.com/api/v1`
- **Content-Type**: `application/json`
- **Authentication**: Custom token-based authentication
- **Authorization Header**: `Authorization: Bearer <auth_token>`
- **SSL**: Required (all requests must use HTTPS in production)
- **CORS**: Enabled for `https://*.itsm-gss.netlify.app` domains

## Authentication Endpoints

### Login

```
POST /api/v1/login
```

**Request Body:**

```json
{
  "email": "admin@example.com",
  "password": "password123",
  "subdomain": "company"
}
```

**Success Response (200):**

```json
{
  "message": "Login successful",
  "auth_token": "a1b2c3d4e5f6789012345678901234567890abcd",
  "user": {
    "id": 1,
    "email": "admin@example.com",
    "name": "John Doe",
    "role": "domain_admin",
    "organization_id": 1,
    "team_id": null,
    "team_ids": []
  },
  "subdomain": "company",
  "organization_id": 1
}
```

**Error Response (401):**

```json
{
  "error": "Invalid email or password"
}
```

**Error Response (404):**

```json
{
  "error": "Organization not found"
}
```

**Error Response (422):**

```json
{
  "error": "User role is invalid or missing"
}
```

### Logout

```
DELETE /api/v1/logout
```

**Headers:** `Authorization: Bearer <auth_token>`
**Success Response (200):**

```json
{
  "message": "Logged out successfully"
}
```

**Error Response (401):**

```json
{
  "error": "Invalid token"
}
```

### Verify Token

```
GET /api/v1/verify
```

**Headers:** `Authorization: Bearer <auth_token>`
**Success Response (200):**

```json
{
  "message": "Token valid",
  "role": "domain_admin"
}
```

**Error Response (401):**

```json
{
  "error": "Invalid token"
}
```

### Register Organization with Admin

```
POST /api/v1/register
```

**Request Body:**

```json
{
  "organization": {
    "name": "Company Name",
    "email": "contact@company.com",
    "phone_number": "+1234567890",
    "address": "123 Main St, City, State",
    "subdomain": "company",
    "website": "https://company.com"
  },
  "admin": {
    "name": "John Doe",
    "email": "admin@company.com",
    "password": "password123",
    "password_confirmation": "password123",
    "username": "johndoe",
    "position": "IT Manager",
    "department_id": 1
  }
}
```

**Success Response (201):**

```json
{
  "message": "Registration successful",
  "organization": {
    "id": 1,
    "name": "Company Name",
    "subdomain": "company"
  },
  "admin": {
    "id": 1,
    "name": "John Doe",
    "email": "admin@company.com",
    "username": "johndoe",
    "auth_token": "a1b2c3d4e5f6789012345678901234567890abcd"
  }
}
```

**Error Response (422):**

```json
{
  "error": "Validation failed",
  "details": {
    "email": ["has already been taken"],
    "subdomain": ["has already been taken"]
  }
}
```

### Verify Admin

```
GET /api/v1/verify_admin
```

**Headers:** `Authorization: Bearer <auth_token>`
**Success Response (200):** Empty body
**Error Response (403):** Empty body

### Password Reset

```
POST /api/v1/password/reset
```

**Request Body:**

```json
{
  "email": "user@example.com"
}
```

### Password Update

```
POST /api/v1/password/update
```

**Request Body:**

```json
{
  "token": "reset_token",
  "password": "new_password123"
}
```

## Global Endpoints

### Validate Subdomain

```
POST /api/v1/validate_subdomain
```

**Request Body:**

```json
{
  "subdomain": "company-name"
}
```

### Profile

```
GET /api/v1/profile
```

**Headers:** `Authorization: Bearer <auth_token>`

## Organization-Specific Endpoints

All organization endpoints require:

- The organization subdomain as a parameter
- Valid authentication token in header: `Authorization: Bearer <auth_token>`

### Organization Dashboard

```
GET /api/v1/organizations/{subdomain}/dashboard
```

**Headers:** `Authorization: Bearer <auth_token>`

### Organization Profile

```
GET /api/v1/organizations/{subdomain}/profile
```

**Headers:** `Authorization: Bearer <token>`

### Organization Tickets

```
GET /api/v1/organizations/{subdomain}/tickets
```

**Headers:** `Authorization: Bearer <token>`

### Organization Users

```
GET /api/v1/organizations/{subdomain}/users
```

**Headers:** `Authorization: Bearer <token>`

### Add User to Organization

```
POST /api/v1/organizations/{subdomain}/add_user
```

**Headers:** `Authorization: Bearer <token>`
**Request Body:**

```json
{
  "user": {
    "email": "newuser@example.com",
    "name": "New User",
    "role": "member"
  }
}
```

### Organization Settings

```
GET /api/v1/organizations/{subdomain}/settings
PUT /api/v1/organizations/{subdomain}/settings
```

**Headers:** `Authorization: Bearer <token>`

### Upload Logo

```
POST /api/v1/organizations/{subdomain}/upload_logo
```

**Headers:** `Authorization: Bearer <token>`
**Content-Type:** `multipart/form-data`

### Register Admin

```
POST /api/v1/organizations/{subdomain}/register_admin
```

**Request Body:**

```json
{
  "admin": {
    "email": "admin@example.com",
    "password": "password123",
    "name": "Admin User"
  }
}
```

## Users Management

### List Users

```
GET /api/v1/organizations/{subdomain}/users
```

### Show User

```
GET /api/v1/organizations/{subdomain}/users/{id}
```

### Create User

```
POST /api/v1/organizations/{subdomain}/users
```

**Request Body:**

```json
{
  "user": {
    "email": "user@example.com",
    "name": "User Name",
    "role": "member"
  }
}
```

### Update User

```
PUT /api/v1/organizations/{subdomain}/users/{id}
```

### Delete User

```
DELETE /api/v1/organizations/{subdomain}/users/{id}
```

### User Tickets

```
GET /api/v1/organizations/{subdomain}/users/{id}/tickets
```

### User Problems

```
GET /api/v1/organizations/{subdomain}/users/{id}/problems
```

## Teams Management

### List Teams

```
GET /api/v1/organizations/{subdomain}/teams
```

### Show Team

```
GET /api/v1/organizations/{subdomain}/teams/{id}
```

### Create Team

```
POST /api/v1/organizations/{subdomain}/teams
```

**Request Body:**

```json
{
  "team": {
    "name": "Development Team",
    "description": "Main development team"
  }
}
```

### Update Team

```
PUT /api/v1/organizations/{subdomain}/teams/{id}
```

### Delete Team

```
DELETE /api/v1/organizations/{subdomain}/teams/{id}
```

### Team Users

```
GET /api/v1/organizations/{subdomain}/teams/{id}/users
```

## Tickets Management

### List Tickets

```
GET /api/v1/organizations/{subdomain}/tickets
```

### Show Ticket

```
GET /api/v1/organizations/{subdomain}/tickets/{id}
```

### Create Ticket

```
POST /api/v1/organizations/{subdomain}/tickets
```

**Request Body:**

```json
{
  "ticket": {
    "title": "Issue with login",
    "description": "Users cannot log in",
    "priority": "high",
    "category": "bug"
  }
}
```

### Update Ticket

```
PUT /api/v1/organizations/{subdomain}/tickets/{id}
```

### Delete Ticket

```
DELETE /api/v1/organizations/{subdomain}/tickets/{id}
```

### Export Tickets

```
GET /api/v1/organizations/{subdomain}/tickets/export
```

### Assign Ticket to User

```
POST /api/v1/organizations/{subdomain}/tickets/{id}/assign_to_user
```

**Request Body:**

```json
{
  "user_id": 123
}
```

### Escalate Ticket to Problem

```
POST /api/v1/organizations/{subdomain}/tickets/{id}/escalate_to_problem
```

### Resolve Ticket

```
POST /api/v1/organizations/{subdomain}/tickets/{id}/resolve
```

## Problems Management

### List Problems

```
GET /api/v1/organizations/{subdomain}/problems
```

### Show Problem

```
GET /api/v1/organizations/{subdomain}/problems/{id}
```

### Create Problem

```
POST /api/v1/organizations/{subdomain}/problems
```

**Request Body:**

```json
{
  "problem": {
    "title": "System Performance Issue",
    "description": "System is running slow",
    "severity": "critical"
  }
}
```

### Update Problem

```
PUT /api/v1/organizations/{subdomain}/problems/{id}
```

### Delete Problem

```
DELETE /api/v1/organizations/{subdomain}/problems/{id}
```

## Notifications Management

### List Notifications

```
GET /api/v1/organizations/{subdomain}/notifications
```

### Show Notification

```
GET /api/v1/organizations/{subdomain}/notifications/{id}
```

### Create Notification

```
POST /api/v1/organizations/{subdomain}/notifications
```

### Update Notification

```
PUT /api/v1/organizations/{subdomain}/notifications/{id}
```

### Delete Notification

```
DELETE /api/v1/organizations/{subdomain}/notifications/{id}
```

### Mark Notification as Read

```
PATCH /api/v1/organizations/{subdomain}/notifications/{id}/mark_as_read
```

## WebSocket Support

WebSocket connections are available at:

```
wss://itsm-api.onrender.com/cable
```

## File Upload

The API uses Cloudinary for file storage. Logo uploads should be sent as multipart form data.

## Error Responses

All endpoints may return the following error formats:

### 400 Bad Request

```json
{
  "error": "Invalid parameters",
  "details": ["Email is required", "Password is too short"]
}
```

### 401 Unauthorized

```json
{
  "error": "Unauthorized",
  "message": "Invalid or missing authentication token"
}
```

### 403 Forbidden

```json
{
  "error": "Forbidden",
  "message": "You don't have permission to access this resource"
}
```

### 404 Not Found

```json
{
  "error": "Not found",
  "message": "The requested resource was not found"
}
```

### 422 Unprocessable Entity

```json
{
  "error": "Validation failed",
  "details": {
    "email": ["has already been taken"],
    "password": ["is too short"]
  }
}
```

### 500 Internal Server Error

```json
{
  "error": "Internal server error",
  "message": "Something went wrong on our end"
}
```

## Rate Limiting

_[Details needed about rate limiting policies]_

## Pagination

_[Details needed about pagination format]_

## Testing Information

### Base URLs

- **Development**: `http://localhost:3000/api/v1` (with CORS enabled)
- **Production**: `https://itsm-api.onrender.com/api/v1`

### CORS Configuration

- **Development**: Allows localhost:3000, localhost:3001, and \*.lvh.me domains
- **Production**: Allows \*.itsm-gss.netlify.app domains
- **Credentials**: Enabled (cookies and authorization headers supported)
- **Exposed Headers**: Authorization, X-Organization-Subdomain

### Important Notes

- All production requests must use HTTPS
- The API uses Sidekiq for background job processing
- Email notifications are sent via SendGrid
- File uploads are handled by Cloudinary
