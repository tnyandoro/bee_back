module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      # Adjust based on your authentication, e.g., using auth_token
      if user = User.find_by(auth_token: request.headers['Authorization']&.split&.last)
        user
      else
        reject_unauthorized_connection
      end
    end
  end
end