# app/controllers/concerns/authentication.rb
module Authentication
    extend ActiveSupport::Concern
  
    included do
      before_action :authenticate_user, except: [:create] # Skip for login
    end
  
    private
  
    def authenticate_user
      token = request.headers["Authorization"]&.split(" ")&.last
      @current_user = User.find_by(auth_token: token) if token
  
      unless @current_user
        render_error(message: ErrorCodes::Messages::NOT_AUTHORIZED, error_code: ErrorCodes::Codes::NOT_AUTHORIZED, status: :unauthorized)
      end
    end
  
    def current_user
      @current_user
    end
  end