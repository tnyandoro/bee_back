Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(
      'http://localhost:3000',
      'http://lvh.me:3000',
      'http://localhost:3001', 
      'http://lvh.me:3001',
      /\.lvh\.me(:\d+)?$/ # Allow all subdomains with optional port
    )

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true,
      expose: ['Authorization'],
      max_age: 600
  end
end
