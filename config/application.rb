require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
# Active Storage, Action Mailbox, and Action Text are omitted — this API does not use them.

Bundler.require(*Rails.groups)

module Payments
  class Application < Rails::Application
    config.load_defaults 8.1

    config.autoload_lib(ignore: %w[assets tasks])

    config.api_only = true

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
