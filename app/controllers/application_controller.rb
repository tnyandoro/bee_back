# frozen_string_literal: true
class ApplicationController < ActionController::API
  before_action :authenticate_request!

  private

  # Checks if the JWT token in headers is valid
  def authenticate_request!
    header = request.headers['Authorization']
    token = header.split(' ').last if header

    unless token
      render json: { error: 'Missing token' }, status: :unauthorized
      return
    end

    begin
      decoded = JwtService.decode(token)
      @current_user = User.find(decoded[:user_id])
    rescue JWT::ExpiredSignature
      render json: { error: 'Token expired' }, status: :unauthorized
    rescue JWT::DecodeError
      render json: { error: 'Invalid token' }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
end
