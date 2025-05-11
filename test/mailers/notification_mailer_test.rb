# frozen_string_literal: true

require 'test_helper'

class NotificationMailerTest < ActionMailer::TestCase
  setup do
    @organization = organizations(:greensoft)
    @user = users(:support_tech)
    @ticket = tickets(:email_issue)
    @notification = Notification.create!(
      user: @user,
      organization: @organization,
      message: "You have been assigned a new ticket: #{@ticket.title} (#{@ticket.ticket_number})",
      notifiable: @ticket,
      read: false
    )
  end

  test "notify_user sends email with correct details" do
    email = NotificationMailer.notify_user(@notification).deliver_now

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@user.email], email.to
    assert_equal "notifications@greensoft.com", email.from.first
    assert_equal "New Notification: You have been assigned a new ticket: #{@ticket.title.truncate(50)}", email.subject
    assert_match @notification.message, email.text_part.body.to_s
    assert_match @ticket.ticket_number, email.html_part.body.to_s
  end
end