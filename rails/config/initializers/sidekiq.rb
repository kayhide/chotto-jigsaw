host = ENV.fetch('REDIS_HOST', 'localhost')
port = ENV.fetch('REDIS_PORT', 6379)
url = ENV.fetch('REDIS_URL', "redis://#{host}:#{port.to_s}")
app_name = Rails.application.class.module_parent_name.underscore

Sidekiq.configure_client do |config|
  config.redis = {
    url: url,
    namespace: "sidekiq_#{app_name}_#{Rails.env}",
  }.merge((size = ENV['REDIS_CLIENT_SIZE']) ? { size: size.to_i } : {})
end

Sidekiq.configure_server do |config|
  config.redis = {
    url: url,
    namespace: "sidekiq_#{app_name}_#{Rails.env}",
  }.merge((size = ENV['REDIS_SERVER_SIZE']) ? { size: size.to_i } : {})
end
