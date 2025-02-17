class ApplicationController < ActionController::Base
    include Pundit::Authorization
  
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  
    private
  
    def user_not_authorized
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to(request.referrer || root_path)
    end

    def current_user
        @current_user ||= User.find_by(id: session[:user_id]) # Adjust based on your auth system
    end
  end
  