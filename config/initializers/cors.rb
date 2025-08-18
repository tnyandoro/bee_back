# Rails.application.config.middleware.insert_before 0, Rack::Cors do
#   # Development environment
#   if Rails.env.development?
#     allow do
#       origins(
#         'http://localhost:3000',
#         'http://lvh.me:3000',
#         'http://localhost:3001',
#         'http://lvh.me:3001',
#         'https://d10tmedpan81b6.cloudfront.net',
#         'https://gsolve360.greensoftsolutions.net',
#         'https://www.gsolve360.greensoftsolutions.net',
#         'https://www.greensoftsolutions.net',
#         /\.lvh\.me(:\d+)?$/,
#         /\.localhost(:\d+)?$/
#       )

#       resource '*',
#         headers: :any,
#         methods: [:get, :post, :put, :patch, :delete, :options, :head],
#         credentials: true,
#         expose: ['Authorization', 'X-Organization-Subdomain'],
#         max_age: 600
#     end
#   end

#   # Production environment
#   if Rails.env.production?
#     allow do
#       origins 'https://itsm-gss.netlify.app', /https:\/\/.*\.greensoftsolutions\.net/

#       resource '*',  # Allow all API routes
#         headers: :any,
#         methods: [:get, :post, :put, :patch, :delete, :options, :head],
#         credentials: true,
#         expose: ['Authorization', 'X-Organization-Subdomain'],
#         max_age: 600
#     end
#   end
# end

# config/initializers/cors.rb

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  # Development environment
  if Rails.env.development?
    allow do
      origins(
        'http://localhost:3000',
        'http://lvh.me:3000',
        'http://localhost:3001',
        'http://lvh.me:3001',
        'https://d10tmedpan81b6.cloudfront.net',
        'https://gsolve360.greensoftsolutions.net',
        'https://www.gsolve360.greensoftsolutions.net',
        'https://www.greensoftsolutions.net',
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

  # Production environment
  if Rails.env.production?
    allow do
      origins(
        'https://www.gsolve360.greensoftsolutions.net',
        'https://gsolve360.greensoftsolutions.net',
        'https://itsm-gss.netlify.app',
        /\.greensoftsolutions\.net$/  # allows all subdomains of greensoftsolutions.net
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

