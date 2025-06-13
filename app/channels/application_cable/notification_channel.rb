module ApplicationCable
  class NotificationChannel < ApplicationCable::Channel
    def subscribed
      stream_for current_user
    end

    def unsubscribed
      # Cleanup if needed
    end
  end
end