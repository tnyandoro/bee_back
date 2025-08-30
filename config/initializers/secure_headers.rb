# frozen_string_literal: true

Rails.application.config.action_dispatch.default_headers.merge!({
  # Clickjacking protection
  "X-Frame-Options" => "DENY",

  # XSS protection for legacy browsers
  "X-XSS-Protection" => "1; mode=block",

  # Prevent MIME type sniffing
  "X-Content-Type-Options" => "nosniff",

  # Control referrer information
  "Referrer-Policy" => "strict-origin-when-cross-origin",

  # Force HTTPS (HSTS)
  "Strict-Transport-Security" => "max-age=31536000; includeSubDomains",

})
