# config/initializers/database_connection.rb

if Rails.env.production?
  # === DO NOT MODIFY FROZEN CONFIG ===
  # Rails 7.1+ freezes ActiveRecord::DatabaseConfigurations::HashConfig#config
  # So we cannot use: config.configuration_hash.merge!
  #
  # Instead, set pool/connection options in database.yml or DATABASE_URL
  #
  # Example DATABASE_URL:
  # postgresql://user:pass@host/db?pool=2&timeout=10000&connect_timeout=30&checkout_timeout=30&reaping_frequency=10

  # === Optional: Add retry logic for startup ===
  retries = 0
  max_retries = 10  # Increase if needed on cold boot
  initial_wait = 3

  Rails.logger.info "Attempting to establish database connection..."

  begin
    ActiveRecord::Base.connection.execute("SELECT 1") if ActiveRecord::Base.connection.active?
  rescue => e
    # Connection not established or inactive
    ActiveRecord::Base.establish_connection
  end

  begin
    ActiveRecord::Base.connection.execute("SELECT 1")
    Rails.logger.info "Database connected successfully"
  rescue PG::ConnectionBad, ActiveRecord::ConnectionNotEstablished => e
    retries += 1
    if retries <= max_retries
      wait_time = [initial_wait * (2 ** (retries - 1)), 30].min  # Exponential backoff
      Rails.logger.warn "Database connection failed (attempt #{retries}/#{max_retries}): #{e.message}. Retrying in #{wait_time}s..."
      sleep(wait_time)
      retry
    else
      Rails.logger.error "Database connection failed after #{max_retries} attempts: #{e.message}"
      raise e
    end
  rescue => e
    Rails.logger.error "Unexpected error connecting to database: #{e.class} - #{e.message}"
    raise e
  end
end