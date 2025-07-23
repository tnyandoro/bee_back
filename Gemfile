source "https://rubygems.org"

ruby "3.3.6"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.1.5", ">= 7.1.5.1"

gem 'jsonapi-serializer', '~> 2.2'

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

gem 'pundit'

gem 'jwt', '~> 2.10', '>= 2.10.1'

gem 'stringio', '~> 3.1.2'

gem 'cloudinary'

gem 'openurl', '~> 1.0'

gem 'caxlsx'
gem 'caxlsx_rails'

gem "csv"           # Built-in in Ruby for CSV
gem "roo"           # For reading various spreadsheet formats

# Use ActiveModel has_secure_token for generating unique tokens
gem "active_model_secure_token"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Redis adapter to run Action Cable in production
gem "redis", ">= 4.0.1"
gem 'better_errors', '~> 2.9', '>= 2.9.1'

# SendGrid integration for ActionMailer
gem 'sendgrid-actionmailer', '~> 3.2'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

# gem 'pagy', '~> 9.3', '>= 9.3.3'
gem 'will_paginate', '~> 3.3'

gem 'strong_migrations' 

gem 'sidekiq-cron'
gem 'business_time'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
gem "rack-cors"

# Use Rack Attack to throttle and block abusive requests
gem "rack-attack"

gem 'dotenv-rails', groups: [:development, :test]
gem 'paper_trail'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  # gem "debug", platforms: %i[ mri windows ]
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
  gem 'letter_opener'
  gem 'eventmachine', '~> 1.2.7'
  gem 'eventmachine', '~> 1.2.7'
  gem 'mailcatcher'
end

group :test do
  gem "factory_bot_rails"
end

group :production do
  # gem 'rails_12factor' # Helps with logging and static assets on Heroku-like platforms
end