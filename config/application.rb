require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module FlowingVotins
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # TELL RAILS TO USE OUR ROUTES FOR ERROR HANDLING
		config.exceptions_app = self.routes

    begin
			config.before_configuration do
				# Read REDIS configuration from ENV variables
				if Rails.application.credentials.dig(:redis, :session, :ssl_port).present?
					config.redis_session_url = "rediss://:#{Rails.application.credentials.dig(:redis, :session, :password)}@#{Rails.application.credentials.dig(:redis, :session, :hostname)}:#{Rails.application.credentials.dig(:redis, :session, :ssl_port)}/#{ENV.fetch('REDIS_SESSION_DB', '0')}"
				else
					config.redis_session_url = "redis://:#{Rails.application.credentials.dig(:redis, :session, :password)}@#{Rails.application.credentials.dig(:redis, :session, :hostname)}:#{Rails.application.credentials.dig(:redis, :session, :port)}/#{ENV.fetch('REDIS_SESSION_DB', '0')}"
				end

				if Rails.application.credentials.dig(:redis, :cache, :ssl_port).present?
					config.redis_cache_url = "rediss://:#{Rails.application.credentials.dig(:redis, :cache, :password)}@#{Rails.application.credentials.dig(:redis, :cache, :hostname)}:#{Rails.application.credentials.dig(:redis, :cache, :ssl_port)}/#{ENV.fetch('REDIS_CACHE_DB', '0')}"
				else
					config.redis_cache_url = "redis://:#{Rails.application.credentials.dig(:redis, :cache, :password)}@#{Rails.application.credentials.dig(:redis, :cache, :hostname)}:#{Rails.application.credentials.dig(:redis, :cache, :port)}/#{ENV.fetch('REDIS_CACHE_DB', '0')}"
				end
			end
		rescue => @ex
			puts @ex.message
			throw @ex
		end
  end
end
