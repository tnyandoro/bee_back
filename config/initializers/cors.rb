# Rails.application.config.middleware.insert_before 0, Rack::Cors do
#   allow do
#     # Development
#     origins 'http://localhost:3000', 'http://localhost:3001',
#             'http://127.0.0.1:3000', 'http://127.0.0.1:3001',
#             /\.localhost(:\d+)?$/, /\.lvh\.me(:\d+)?$/

#     resource '/api/v1/*',
#       headers: :any,
#       methods: [:get, :post, :put, :patch, :delete, :options, :head],
#       credentials: true,
#       expose: ['Authorization', 'X-Organization-Subdomain'],
#       max_age: 600

#     resource '/organizations/*',
#       headers: :any,
#       methods: [:get, :post, :put, :patch, :delete, :options, :head],
#       credentials: true,
#       expose: ['Authorization', 'X-Organization-Subdomain'],
#       max_age: 600
#   end

#   allow do
#     # Production
#     origins 'https://d10tmedpan81b6.cloudfront.net','https://itsm-gss.netlify.app',
#             'https://itsm-api-w8vr.onrender.com','https://gsolve360.netlify.app',
#             /\.greensoftsolutions\.net$/

#     resource '/api/v1/*',
#       headers: :any,
#       methods: [:get, :post, :put, :patch, :delete, :options, :head],
#       credentials: true,
#       expose: ['Authorization', 'X-Organization-Subdomain'],
#       max_age: 600

#     resource '/organizations/*',
#       headers: :any,
#       methods: [:get, :post, :put, :patch, :delete, :options, :head],
#       credentials: true,
#       expose: ['Authorization', 'X-Organization-Subdomain'],
#       max_age: 600
#   end
# end
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Development
    origins 'http://localhost:3000', 'http://localhost:3001',
            'http://127.0.0.1:3000', 'http://127.0.0.1:3001',
            /\.localhost(:\d+)?$/, /\.lvh\.me(:\d+)?$/

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true,
      expose: ['Authorization', 'X-Organization-Subdomain'],
      max_age: 600
  end

  allow do
    # Production
    origins 'https://d10tmedpan81b6.cloudfront.net',
            'https://itsm-gss.netlify.app',
            'https://itsm-api-w8vr.onrender.com',
            'https://gsolve360.netlify.app',
            /\.greensoftsolutions\.net$/

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true,
      expose: ['Authorization', 'X-Organization-Subdomain'],
      max_age: 600
  end
end
