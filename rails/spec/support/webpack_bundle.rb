Module.new do
  RSpec.configure do |config|
    config.before type: :request do
      allow_any_instance_of(WebpackBundleHelper).to receive(:asset_bundle_path)
    end
  end
end
