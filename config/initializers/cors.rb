# config/initializers/cors.rb

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Local development
    origins 'http://localhost:3000', 'http://localhost:3001',
            'http://lvh.me:3000', 'http://lvh.me:3001',
            /\.localhost(:\d+)?$/, /\.lvh\.me(:\d+)?$/

    resource '/api/v1/*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true,
      expose: ['Authorization', 'X-Organization-Subdomain'],
      max_age: 600
  end

  allow do
    # Production origins
    origins 'https://d10tmedpan81b6.cloudfront.net',
            'https://gsolve360.greensoftsolutions.net',
            'https://www.gsolve360.greensoftsolutions.net',
            'https://www.greensoftsolutions.net'

    resource '/api/v1/*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true,
      expose: ['Authorization', 'X-Organization-Subdomain'],
      max_age: 600
  end
end
