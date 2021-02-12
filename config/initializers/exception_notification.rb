require 'exception_notification/rails'

ExceptionNotification.configure do |config|
  # Ignore additional exception types.
  # ActiveRecord::RecordNotFound, Mongoid::Errors::DocumentNotFound, AbstractController::ActionNotFound and ActionController::RoutingError are already added.
  # config.ignored_exceptions += %w{ActionView::TemplateError CustomError}

  # Adds a condition to decide when an exception must be ignored or not.
  # The ignore_if method can be invoked multiple times to add extra conditions.
  # config.ignore_if do |exception, options|
  #   not Rails.env.production?
  # end

  # Notifiers =================================================================

  # Email notifier sends notifications by email.
  #config.add_notifier :email, {
  #  :email_prefix         => "[LAWLY-ERROR] ",
  #  :sender_address       => %{"Notifier" <notifier@lawly.fi>},
  #  :exception_recipients => %w{it-admin@lawly.fi}
  #}

  # Campfire notifier sends notifications to your Campfire room. Requires 'tinder' gem.
  # config.add_notifier :campfire, {
  #   :subdomain => 'my_subdomain',
  #   :token => 'my_token',
  #   :room_name => 'my_room'
  # }

  # HipChat notifier sends notifications to your HipChat room. Requires 'hipchat' gem.
  # config.add_notifier :hipchat, {
  #   :api_token => 'my_token',
  #   :room_name => 'my_room'
  # }

  # Webhook notifier sends notifications over HTTP protocol. Requires 'httparty' gem.
  # config.add_notifier :webhook, {
  #   :url => 'http://example.com:5555/hubot/path',
  #   :http_method => :post
  # }
  #if Rails.application.credentials.dig(:teams, :webhook_url).present?
  #  config.add_notifier :teams, {
  #    webhook_url: Rails.application.credentials.dig(:teams, :webhook_url),
  #    app_name: Rails.env
  #  }
  #end

  # Application Insights notifier sends notifications over HTTP protocol. Requires 'application_insights' gem.
  # config.add_notifier :application_insight, {
  #   instrumentation_key: 'instrumentation_key',
  #   instance_id: 'custom app instance id'
  # }
  #if Rails.application.credentials.dig(:azure, :application_insights, :instrumentation_key).present?
  #  config.add_notifier :application_insights, {
  #    instrumentation_key: Rails.application.credentials.dig(:azure, :application_insights, :instrumentation_key),
  #    app_name: Rails.env
  #  }
  #end

end
