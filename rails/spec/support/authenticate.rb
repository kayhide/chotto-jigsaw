Module.new do
  def authenticate_user
    let(:current_user) { @current_user }

    before do
      @current_user = block_given? ? yield : FactoryBot.create(:user)

      allow(controller).to receive(:authenticate!)
      allow(controller).to receive(:current_user_id) { current_user.id }
      allow(controller).to receive(:current_user) { current_user }
    end
  end

  RSpec.configure do |config|
    config.extend self, type: :controller
  end
end

Module.new do
  def authenticate_user
    let(:current_user) { @current_user }

    before do
      @current_user = block_given? ? yield : FactoryBot.create(:user)
      post url_for([:login]), params: { login: { email: current_user.email } }
    end
  end

  RSpec.configure do |config|
    config.extend self, type: :request
  end
end
