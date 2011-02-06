Mjolk::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false
  # log level
  config.log_level = :debug

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # required for devise
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }

  # memcached
  #config.cache_store = :dalli_store
  # Global enable/disable all memcached usage
  config.perform_caching = false
  # Disable/enable fragment and page caching in ActionController
  config.action_controller.perform_caching = false
  # The underlying cache store to use.
  #config.cache_store = :file_store, "#{Rails.root.to_s}/tmp/cache_loc/"
  #config.cache_store = :dalli_store, 'localhost:11211'
end

