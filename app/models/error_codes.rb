class ErrorCodes

  module Codes

    # NOTE: Convention for errors is:
    #   1XXX errors are reserved for General App errors
    #   2XXX errors are reserved for General Controller errors
    #   3XXX errors are reserved for Security errors
    #   4XXX errors are reserved for Specific Controller errors

    # General App Errors (1XXX errors)
    SUBDOMAIN_MISSING = 1001
    ORGANIZATION_NOT_FOUND = 1002
    ORGANIZATION_NOT_FOUND_FOR_SUBDOMAIN = 1003
    USER_NOT_FOUND = 1004
    USER_DOES_NOT_BELONG_TO_ORGANIZATION = 1005
    USER_DOES_NOT_BELONG_TO_TEAM = 1006
    VALIDATION_FAILED = 1007
    INVALID_PAGINATION_PARAMETERS = 1008

    # General Controller Errors
    UNAUTHORIZED = 2001
    UNAUTHENTICATED = 2002
    FORBIDDEN = 2003
    NOT_FOUND = 2004
    INTERNAL_SERVER_ERROR = 2005

    # Security Errors
    MISSING_TOKEN = 3001
    INVALID_TOKEN = 3002
    EXPIRED_TOKEN = 3003
    INVALID_OR_EXPIRED_TOKEN = 3004
    INVALID_OR_EXPIRED_REFRESH_TOKEN = 3005

    # Comments Controller Errors
    FAILED_TO_CREATE_COMMENT = 4001

    # Documents Controller Errors
    FILE_NOT_ATTACHED = 4002

    # Notifications Controller Errors
    NOTIFICATION_NOT_FOUND = 4003

    # Organizations Controller Errors
    FAILED_TO_CREATE_ORGANIZATION = 4004
    FAILED_TO_UPDATE_ORGANIZATION = 4005
    FAILED_TO_DELETE_ORGANIZATION = 4006
    FAILED_TO_ADD_USER = 4007

    # Passwords Controller Errors
    PASSWORD_RESET_FAILED = 4008
    PASSWORD_AND_CONF_REQUIRED = 4009
    PASSWORDS_DO_NOT_MATCH = 4010
    PASSWORD_NOT_LONG_ENOUGH = 4011

    # Problems Controller Errors
    UNAUTHORIZED_TO_CREATE_PROBLEM = 4012
    UNAUTHORIZED_TO_UPDATE_PROBLEM = 4013
    UNAUTHORIZED_TO_DELETE_PROBLEM = 4014
    FAILED_TO_CREATE_PROBLEM = 4015
    FAILED_TO_UPDATE_PROBLEM = 4016
    FAILED_TO_DELETE_PROBLEM = 4017

    # Sessions Controller Errors
    INVALID_USERNAME_OR_PASSWORD = 4018
    USER_ROLE_MISSING_OR_INVALID = 4019

    # Settings Controller Errors
    MISSING_KEY_OR_VALUE = 4020
    FAILED_TO_SAVE_SETTING = 4021

    # SLA Configurations Controller Errors
    FAILED_TO_UPDATE_SLA = 4022
    UNAUTHORIZED_TO_UPDATE_SLA = 4023

    # Teams Controller Errors
    TEAM_NOT_FOUND = 4024
    FAILED_TO_CREATE_TEAM = 4025
    FAILED_TO_UPDATE_TEAM = 4026
    FAILED_TO_DELETE_TEAM = 4027
    UNAUTHORIZED_TO_MANAGE_TEAMS = 4028

    # Tickets Controller Errors
    TICKET_NOT_FOUND = 4028
    TICKET_NOT_FOUND_FOR_ORGANIZATION = 4030
    UNAUTHORIZED_TO_VIEW_TICKETS = 4031
    UNAUTHORIZED_TO_CREATE_TICKETS = 4032
    UNAUTHORIZED_TO_UPDATE_TICKETS = 4033
    UNAUTHORIZED_TO_DELETE_TICKETS = 4034
    UNAUTHORIZED_TO_ASSIGN_TICKETS = 4035
    UNAUTHORIZED_TO_ESCALATE_TICKETS = 4036
    UNAUTHORIZED_TO_RESOLVE_TICKETS = 4037
    FAILED_TO_CREATE_TICKET = 4038
    FAILED_TO_UPDATE_TICKET = 4039
    FAILED_TO_DELETE_TICKET = 4040
    FAILED_TO_ASSIGN_TICKET = 4041
    FAILED_TO_ESCALATE_TICKET = 4042
    FAILED_TO_RESOLVE_TICKET = 4043
    INVALID_TICKET_CATEGORY = 4044
    INVALID_TICKET_STATUS = 4045
    INVALID_TICKET_TYPE = 4046
    TICKET_ALREADY_RESOLVED_OR_CLOSED = 4047
    TICKET_ATTACHMENT_NOT_FOUND = 4048
    UNAUTHORIZED_TO_CREATE_TICKET_TYPE = 4049
    UNAUTHORIZED_TO_CHANGE_TICKET_URGENCY = 4050
    UNAUTHORIZED_TO_RESOLVE_TICKET_TYPE = 4051
  end

  module Messages

    # General App Errors
    SUBDOMAIN_MISSING = "Subdomain is missing"
    ORGANIZATION_NOT_FOUND = "Organization not found"
    ORGANIZATION_NOT_FOUND_FOR_SUBDOMAIN = "Organization not found for subdomain"
    USER_NOT_FOUND = "User not found"
    USER_DOES_NOT_BELONG_TO_ORGANIZATION = "User does not belong to this organization"
    USER_DOES_NOT_BELONG_TO_TEAM = "User does not belong to this team"
    VALIDATION_FAILED = "Validation failed"
    INVALID_PAGINATION_PARAMETERS = "Invalid pagination parameters"

    # General Controller Errors
    UNAUTHORIZED = "User is not authorized"
    UNAUTHENTICATED = "User is not authenticated"
    FORBIDDEN = "You are not authorized to perform this action"
    NOT_FOUND = "Resource not found"
    INTERNAL_SERVER_ERROR = "Internal server error"

    # Security Errors
    MISSING_TOKEN = "Missing authentication token"
    INVALID_TOKEN = "Invalid authentication token"
    EXPIRED_TOKEN = "Expired authentication token"
    INVALID_OR_EXPIRED_TOKEN = "Invalid or expired authentication token"
    INVALID_OR_EXPIRED_REFRESH_TOKEN = "Invalid or expired refresh token"

    # Comments Controller Errors
    FAILED_TO_CREATE_COMMENT = "Failed to create comment"

    # Documents Controller Errors
    FILE_NOT_ATTACHED = "File not attached"

    # Notifications Controller Errors
    NOTIFICATION_NOT_FOUND = "Notification not found"

    # Organizations Controller Errors
    FAILED_TO_CREATE_ORGANIZATION = "Failed to create organization"
    FAILED_TO_UPDATE_ORGANIZATION = "Failed to update organization"
    FAILED_TO_DELETE_ORGANIZATION = "Failed to delete organization"
    FAILED_TO_ADD_USER = "Failed to add user to organization"

    # Passwords Controller Errors
    PASSWORD_RESET_FAILED = "Failed to reset password"
    PASSWORD_AND_CONF_REQUIRED = "Password and confirmation are required"
    PASSWORDS_DO_NOT_MATCH = "Passwords do not match"
    PASSWORD_NOT_LONG_ENOUGH = "Password must be at least 6 characters long"

    # Problems Controller Errors
    UNAUTHORIZED_TO_CREATE_PROBLEM = "Only team leads or higher can create problems"
    UNAUTHORIZED_TO_UPDATE_PROBLEM = "Only team leads or higher can update problems"
    UNAUTHORIZED_TO_DELETE_PROBLEM = "Only admins can delete problems"
    FAILED_TO_CREATE_PROBLEM = "Failed to create problem"
    FAILED_TO_UPDATE_PROBLEM = "Failed to update problem"
    FAILED_TO_DELETE_PROBLEM = "Failed to delete problem"
    PROBLEM_NOT_FOUND_IN_ORGANIZATION = "Problem not found in this organization"

    # Sessions Controller Errors
    INVALID_USERNAME_OR_PASSWORD = "Invalid username or password"
    USER_ROLE_MISSING_OR_INVALID = "User role is missing or invalid"

    # Settings Controller Errors
    MISSING_KEY_OR_VALUE = "Missing key or value"
    FAILED_TO_SAVE_SETTING = "Failed to save setting"

    # SLA Configurations Controller Errors
    FAILED_TO_UPDATE_SLA = "Failed to update SLA"
    UNAUTHORIZED_TO_UPDATE_SLA = "Only admins can update SLAs"

    # Teams Controller Errors
    TEAM_NOT_FOUND = "Team not found"
    FAILED_TO_CREATE_TEAM = "Failed to create team"
    FAILED_TO_UPDATE_TEAM = "Failed to update team"
    FAILED_TO_DELETE_TEAM = "Failed to delete team"
    UNAUTHORIZED_TO_MANAGE_TEAMS = "You are not authorized to manage teams"

    # Tickets Controller Errors
    TICKET_NOT_FOUND = "Ticket not found"
    TICKET_NOT_FOUND_FOR_ORGANIZATION = "Ticket does not belong to this organization"
    UNAUTHORIZED_TO_VIEW_TICKETS = "You are not authorized to view this ticket"
    UNAUTHORIZED_TO_CREATE_TICKETS = "You are not authorized to create this ticket"
    UNAUTHORIZED_TO_UPDATE_TICKETS = "You are not authorized to update this ticket"
    UNAUTHORIZED_TO_DELETE_TICKETS = "Only admins can delete tickets"
    UNAUTHORIZED_TO_ASSIGN_TICKETS = "You are not authorized to assign tickets"
    UNAUTHORIZED_TO_ESCALATE_TICKETS = "Only team leads or higher can escalate tickets to problems"
    UNAUTHORIZED_TO_RESOLVE_TICKETS = "You are not authorized to resolve tickets"
    FAILED_TO_CREATE_TICKET = "Failed to create tickets"
    FAILED_TO_UPDATE_TICKET = "Failed to update tickets"
    FAILED_TO_DELETE_TICKET = "Failed to delete tickets"
    FAILED_TO_ASSIGN_TICKET = "Failed to assign tickets"
    FAILED_TO_ESCALATE_TICKET = "Failed to escalate tickets"
    FAILED_TO_RESOLVE_TICKET = "Failed to resolve tickets"
    INVALID_TICKET_CATEGORY = "Invalid category. Allowed values are: ###VALID_CATEGORIES###"
    INVALID_TICKET_STATUS = "Invalid status. Allowed values are: ###VALID_STATUSES###"
    INVALID_TICKET_TYPE = "Invalid type. Allowed values are: ###VALID_TICKET_TYPES###"
    TICKET_ALREADY_RESOLVED_OR_CLOSED = "Ticket is already resolved or closed"
    TICKET_ATTACHMENT_NOT_FOUND = "Ticket attachment not found"
    UNAUTHORIZED_TO_CREATE_TICKET_TYPE = "Unauthorized to create ###TICKET_TYPE### tickets"
    UNAUTHORIZED_TO_CHANGE_TICKET_URGENCY = "You are not authorized to change the urgency of this ticket"
    UNAUTHORIZED_TO_RESOLVE_TICKET_TYPE = "Unauthorized to resolve ###TICKET_TYPE### tickets"
  end

end

