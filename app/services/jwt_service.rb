# app/services/jwt_service.rb
class JwtService
  ALGORITHM = 'HS256'
  # Try credentials first, fallback to ENV, then to Rails secret
  SECRET_KEY = Rails.application.credentials.jwt_master_key || 
               ENV['JWT_SECRET_KEY'] || 
               Rails.application.secret_key_base

  def self.encode(payload, exp = 1.hour.from_now)
    if SECRET_KEY.nil?
      Rails.logger.error "JWT SECRET_KEY is nil! Check credentials or environment variables."
      raise "JWT secret key not configured"
    end
    
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY, ALGORITHM)
  end

  def self.decode(token)
    if SECRET_KEY.nil?
      Rails.logger.error "JWT SECRET_KEY is nil! Check credentials or environment variables."
      return nil
    end
    
    decoded, = JWT.decode(token, SECRET_KEY, true, { algorithm: ALGORITHM })
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::VerificationError => e
    Rails.logger.warn "JWT decode failed: #{e.message}"
    nil
  end
end