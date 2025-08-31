# frozen_string_literal: true

require "test_helper"

class Api::V1::TicketsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one) # Regular user
    @admin = users(:admin) # Admin user
    @organization = organizations(:one) # Organization with subdomain "example"
    @team = teams(:one) # Team in organization
    @assignee = users(:two) # User in team
    @subdomain = @organization.subdomain # e.g., "example"
    @host = "#{@subdomain}.lvh.me"
    @token = generate_token_for(@admin)
  end

  test "should create ticket with valid params and generate notification" do
    ticket_params = {
      ticket: {
        title: "Test Ticket",
        description: "This is a test ticket",
        ticket_type: "Incident",
        urgency: "high",
        impact: "high",
        priority: "p1",
        team_id: @team.id,
        assignee_id: @assignee.id,
        ticket_number: "INC/TEST12345678",
        reported_at: "2025-05-08T08:00:00Z",
        caller_name: "Boris",
        caller_surname: "Johnson",
        caller_email: "boris@example.com",
        caller_phone: "07720938746",
        customer: "Johannesburg",
        source: "Web",
        category: "Query",
      }
    }

    assert_difference ["Ticket.count", "Comment.count", "Notification.count"], 1 do
      post api_v1_organization_tickets_url(organization_subdomain: @subdomain),
           params: ticket_params,
           headers: { "Host" => @host, "Authorization" => "Bearer #{@token}" },
           as: :json
    end

    assert_response :created
    response_body = JSON.parse(response.body)
    assert_equal ticket_params[:ticket][:title], response_body["title"]
    assert_equal ticket_params[:ticket][:ticket_number], response_body["ticket_number"]
    assert_equal @team.id, response_body["team_id"]
    assert_equal @assignee.id, response_body["assignee_id"]
    assert_equal "assigned", response_body["status"]

    ticket = Ticket.last
    comment = Comment.last
    notification = Notification.last

    assert_equal "Ticket created by #{@admin.name}", comment.content
    assert_equal @admin.id, comment.user_id
    assert_equal ticket.id, comment.ticket_id

    assert_equal @assignee.id, notification.user_id
    assert_equal @organization.id, notification.organization_id
    assert_equal "You have been assigned a new ticket: #{ticket_params[:ticket][:title]}", notification.message
    assert_equal "Ticket", notification.notifiable_type
    assert_equal ticket.id, notification.notifiable_id
    assert_equal false, notification.read
  end
end