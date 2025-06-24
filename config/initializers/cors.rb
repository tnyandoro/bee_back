# config/initializers/cors.rb

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  # Development environment settings
  if Rails.env.development?
    allow do
      origins(
        'http://localhost:3000',
        'http://lvh.me:3000',
        'http://localhost:3001',
        'http://lvh.me:3001',
        /\.lvh\.me(:\d+)?$/,
        /\.localhost(:\d+)?$/
      )

      resource '*',
        headers: :any,
        methods: [:get, :post, :put, :patch, :delete, :options, :head],
        credentials: true,
        expose: ['Authorization', 'X-Organization-Subdomain'],
        max_age: 600
    end
  end

  # Production environment settings
  if Rails.env.production?
    allow do
      # This regex allows all subdomains of itsm-gss.netlify.app
      origins do |origin, _env|
        Rails.logger.info "🔵 Incoming CORS origin: #{origin}"
        origin.present? && origin.match?(/^https:\/\/([a-z0-9-]+\.)?itsm-gss\.netlify\.app$/)
      end

      resource '*',
        headers: :any,
        methods: [:get, :post, :put, :patch, :delete, :options, :head],
        credentials: true,
        expose: ['Authorization', 'X-Organization-Subdomain'],
        max_age: 600
    end
  end
end
