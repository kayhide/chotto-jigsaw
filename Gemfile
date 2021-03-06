source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.5'

gem 'rails', '~> 6.0.0'

gem 'bootsnap', '>= 1.4.2', require: false
gem 'google-cloud-firestore'
gem 'image_processing', '~> 1.2'
gem 'jwt'
gem 'pg', '>= 0.18', '< 2.0'
gem 'pry-doc'
gem 'pry-rails'
gem 'puma', '~> 3.12'
gem 'rails-i18n'
gem 'redis', '~> 4.0'
gem 'redis-namespace'
gem 'sidekiq'
gem 'sidekiq-history'
gem 'sidekiq-limit_fetch'
gem 'slim-rails'

# rack-2.1.1 has problem with sidekiq web
# https://github.com/rack/rack/pull/1428
gem 'rack', '~> 2.1.4'

# gem 'bcrypt', '~> 3.1.7'

group :development, :test do
  gem 'factory_bot_rails'
  gem 'guard'
  gem 'guard-livereload', require: false
  gem 'guard-rspec'
  gem 'pry-byebug'
  gem 'pry-stack_explorer'
  gem 'rack-livereload'
  gem 'rspec-rails', '~> 4.0.0.beta2'
  gem 'spring-commands-rspec'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  # gem 'capybara', '>= 2.15'
  # gem 'selenium-webdriver'
  # gem 'webdrivers'
end

group :production do
  gem 'aws-sdk-s3'
end
