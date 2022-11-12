require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Vagrant
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Automated tests run with the :async adapter. Otherwise, we need to run
    # Sidekiq for tests, and some tests won't work, since Sidekiq can't see
    # what's run within the testing transaction.
    config.active_job.queue_adapter = :sidekiq
  end
end
