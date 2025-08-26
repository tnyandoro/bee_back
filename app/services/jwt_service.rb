# app/services/jwt_service.rb
class JwtService
  ALGORITHM = 'HS256'
  SECRET_KEY = Rails.application.credentials.jwt_master_key

  def self.encode(payload, exp = 1.hour.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY, ALGORITHM)
  end

  def self.decode(token)
    decoded, = JWT.decode(token, SECRET_KEY, true, { algorithm: ALGORITHM })
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::VerificationError => e
    Rails.logger.warn "JWT decode failed: #{e.message}"
    nil
  end
end
