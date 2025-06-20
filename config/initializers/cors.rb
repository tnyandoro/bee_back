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
        /\.lvh\.me(:\d+)?$/,  # All subdomains of lvh.me with any port
        /\.localhost(:\d+)?$/ # All subdomains of localhost with any port
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
  # config/initializers/cors.rb

  if Rails.env.production?
    allow do
      origins(
        'https://your-production-domain.com',
        'https://app.your-production-domain.com',
        'https://itsm-gss.netlify.app'            
      )

      resource '*',
        headers: :any,
        methods: [:get, :post, :put, :patch, :delete, :options, :head],
        credentials: true,
        expose: ['Authorization', 'X-Organization-Subdomain'],
        max_age: 600
    end
  end
end