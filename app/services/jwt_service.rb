# app/services/jwt_service.rb
class JwtService
  SECRET_KEY = Rails.application.credentials.jwt_secret || ENV['JWT_SECRET']

  def self.encode(payload, exp = 1.hour.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new(decoded)
  end
end
