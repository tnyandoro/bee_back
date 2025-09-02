# frozen_string_literal: true
class ApplicationController < ActionController::API
  before_action :authenticate_request!

  private

  # Checks if the JWT token in headers is valid
  def authenticate_request!
    header = request.headers['Authorization']
    token = header.split(' ').last if header

    unless token
      render_error(message: ErrorCodes::Messages::MISSING_TOKEN, error_code: ErrorCodes::Codes::MISSING_TOKEN, status: :unauthorized)
      return
    end

    begin
      decoded = JwtService.decode(token)
      @current_user = User.find(decoded[:user_id])
    rescue JWT::ExpiredSignature
      render_error(message: ErrorCodes::Messages::EXPIRED_TOKEN, error_code: ErrorCodes::Codes::EXPIRED_TOKEN, status: :unauthorized)
    rescue JWT::DecodeError
      render_error(message: ErrorCodes::Messages::INVALID_TOKEN, error_code: ErrorCodes::Codes::INVALID_TOKEN, status: :unauthorized)
    end
  end

  def current_user
    @current_user
  end
end
