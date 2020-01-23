require_relative 'boot'

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require 'matrix'

module ChottoJigsaw
  class Application < Rails::Application
    config.load_defaults 6.0

    config.active_job.queue_adapter = :sidekiq

    config.generators.system_tests = nil

    config.generators do |g|
      g.test_framework  :rspec,
                        fixtures: true,
                        fixture_replacement: :factory_bot,
                        view_specs:      false,
                        routing_specs:   false,
                        helper_specs:    false,
                        requests_specs:  false

      g.assets          false
      g.helper          false
      g.channel         assets: false
    end

    config.action_view.field_error_proc = Proc.new do |html_tag, instance|
      html_tag.html_safe
    end

    config.i18n.available_locales = [:en, :ja]
    config.i18n.default_locale = :en
  end
end
