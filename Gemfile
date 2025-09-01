source "https://rubygems.org"

ruby "3.3.6"

gem "rails", "~> 7.1.5", ">= 7.1.5.1"

gem 'jsonapi-serializer', '~> 2.2'

# Use PostgreSQL with modern pg gem
gem "pg", "~> 1.5"  # Use newer version for SSL/TLS support

gem "puma", ">= 5.0"
gem 'pundit'
gem 'jwt', '~> 2.10', '>= 2.10.1'
gem 'stringio', '~> 3.1.2'
gem 'cloudinary'
gem 'openurl', '~> 1.0'
gem 'caxlsx'
gem 'caxlsx_rails'

gem "csv"
gem "roo"
# Add to your Gemfile

gem 'active_storage_validations', '~> 3.0', '>= 3.0.1'

# REMOVED: gem "active_model_secure_token" - Rails 7.1+ has this built-in
gem "bcrypt", "~> 3.1.7"
gem 'will_paginate', '~> 3.3'
gem 'strong_migrations'
gem 'sidekiq-cron'
gem 'business_time'
gem 'mini_magick', '~> 4.5', '>= 4.5.1'

gem "bootsnap", require: false
gem "rack-cors"
gem "rack-attack"
gem "redis", ">= 4.0.1"
gem 'dotenv-rails', groups: [:development, :test]
gem 'paper_trail'

# === Active Storage: Required for image/video/pdf processing ===
gem "image_processing", "~> 1.2"  # Required for variants
gem "aws-sdk-s3", require: false  # If using S3 or Cloudinary fallback
gem 'azure-storage-blob', require: false

gem 'clamby' # For virus scanning (optional for local dev)

group :development, :test do
  gem 'better_errors', '~> 2.9', '>= 2.9.1'
end

group :development do
  gem 'letter_opener'
  gem 'mailcatcher'
  # Use eventmachine only if needed
  gem 'eventmachine', '~> 1.2.7'
  gem 'rswag-api'
  gem 'rswag-ui'
  gem 'rswag-specs'
end

group :test do
  gem "factory_bot_rails"
end

# Production-only
group :production do
  # Optional: for logging or Heroku-like platforms
  # gem 'rails_12factor'
end

# === Debugging (uncomment only in dev) ===
group :development do
  gem "debug", platforms: %i[ mri ]
end