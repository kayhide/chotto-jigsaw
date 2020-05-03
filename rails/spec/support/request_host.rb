Module.new do
  RSpec.configure do |config|
    config.before type: :request do
      host! ENV["RAILS_HOST"]
    end
  end
end
