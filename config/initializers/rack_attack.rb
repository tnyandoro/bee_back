class Rack::Attack
  # Throttle login attempts by IP
  throttle('logins/ip', limit: 5, period: 20.seconds) do |req|
    if req.path == '/api/v1/login' && req.post?
      req.ip
    end
  end

  # Optional: Throttle by email param to slow down targeted attacks
  throttle('logins/email', limit: 5, period: 60.seconds) do |req|
    if req.path == '/api/v1/login' && req.post?
      req.params['email'].to_s.downcase.strip.presence
    end
  end

  # Custom response when throttled (new API)
  self.throttled_responder = lambda do |env|
    [
      429,
      { 'Content-Type' => 'application/json' },
      [{ error: 'Too many login attempts. Please try again later.' }.to_json]
    ]
  end
end
