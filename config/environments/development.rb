require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Reload application's code on every request.
  config.enable_reloading = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  # Enable/disable caching. Run rails dev:cache to toggle.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.cache_store = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end

  # Store uploaded files locally
  config.active_storage.service = :local

  # MAILER SETTINGS
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_caching = false
  config.action_mailer.perform_deliveries = true
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
  config.action_mailer.asset_host = 'http://localhost:3000'

  # Print deprecation notices
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations
  config.active_support.disallowed_deprecation = :raise
  config.active_support.disallowed_deprecation_warnings = []

  # Raise error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Highlight code that triggered DB queries
  config.active_record.verbose_query_logs = true

  # Highlight code that enqueued jobs
  config.active_job.verbose_enqueue_logs = true

  # Raise for missing translations (optional)
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with partial names
  config.action_view.annotate_rendered_view_with_filenames = true

  # Raise error when before_action has unknown methods
  config.action_controller.raise_on_missing_callback_actions = true

  # SUBDOMAIN ROUTING SUPPORT
  config.hosts << "watoli.localhost"
  config.hosts << "lvh.me"
  config.hosts << /.+\.lvh\.me/
  config.action_dispatch.tld_length = 1

  # ACTION CABLE (WebSockets) using Redis
  config.action_cable.url = "ws://localhost:3000/cable"
  # config.action_cable.adapter = :redis
  config.action_cable.allowed_request_origins = [
    "http://localhost:3000",
    "http://localhost:3001",
    /http:\/\/localhost:\d+/
  ]

  # config.action_mailer.delivery_method = :smtp
  # config.action_mailer.smtp_settings = {
  #   address: "smtp.sendgrid.net",
  #   port: 587,
  #   authentication: :plain,
  #   user_name: "apikey",
  #   password: "your-sendgrid-api-key", # From SendGrid dashboard
  #   domain: "example.lvh.me"
  # }
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: 'localhost',
  port: 1025
}
config.action_mailer.perform_deliveries = true
config.action_mailer.raise_delivery_errors = true
config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
  config.action_mailer.perform_deliveries = true
  config.action_mailer.default_url_options = { host: "example.lvh.me:3000" }
end
