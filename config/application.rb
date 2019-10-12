require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ChottoJigsaw
  class Application < Rails::Application
    config.load_defaults 6.0

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
  end
end
