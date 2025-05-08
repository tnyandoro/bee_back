Cloudinary.config do |config|
  # Validate required environment variables
  required_vars = ['CLOUDINARY_CLOUD_NAME', 'CLOUDINARY_API_KEY', 'CLOUDINARY_API_SECRET']
  missing_vars = required_vars.select { |var| ENV[var].nil? || ENV[var].empty? }
  
  if missing_vars.any?
    Rails.logger.error "Missing Cloudinary configuration: #{missing_vars.join(', ')}"
    raise "Missing required Cloudinary environment variables: #{missing_vars.join(', ')}" if Rails.env.production?
  end

  config.cloud_name = ENV['CLOUDINARY_CLOUD_NAME']
  config.api_key    = ENV['CLOUDINARY_API_KEY']
  config.api_secret = ENV['CLOUDINARY_API_SECRET']
  config.secure     = true
  config.cdn_subdomain = true
end