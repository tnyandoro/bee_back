# frozen_string_literal: true

class NotificationChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
    Rails.logger.info "User #{current_user.id} subscribed to NotificationChannel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    Rails.logger.info "User #{current_user.id} unsubscribed from NotificationChannel"
  end
end