# Database connection configuration for small Render instances
if Rails.env.production?
  ActiveRecord::Base.configurations.configs_for(env_name: Rails.env).each do |config|
    config.configuration_hash.merge!(
      pool: 2,
      timeout: 10000,
      connect_timeout: 30,
      checkout_timeout: 30,
      reaping_frequency: 10
    )
  end
  
  # Retry connection on startup
  retries = 0
  max_retries = 5
  
  begin
    ActiveRecord::Base.connection
    Rails.logger.info "Database connected successfully"
  rescue PG::ConnectionBad, ActiveRecord::ConnectionNotEstablished => e
    retries += 1
    if retries <= max_retries
      wait_time = retries * 3
      Rails.logger.warn "Database connection failed (attempt #{retries}/#{max_retries}), retrying in #{wait_time} seconds..."
      sleep(wait_time)
      retry
    else
      Rails.logger.error "Database connection failed after #{max_retries} attempts: #{e.message}"
      raise e
    end
  end
end