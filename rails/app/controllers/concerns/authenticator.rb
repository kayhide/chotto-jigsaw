module Authenticator
  extend ActiveSupport::Concern

  attr_reader :auth_token, :auth_token_content, :current_user_id

  JWT_SECRET = Rails.application.credentials.jwt_secret

  def authenticate!
    token, _options = ActionController::HttpAuthentication::Token.token_and_options(request)
    token ||= request.params[:token]

    raise Api::NoToken if token.nil?

    @auth_token = token
    @auth_token_content = from_jwt token
    @current_user_id = @auth_token_content.first["user"]["id"]
  rescue JWT::DecodeError => e
    raise Api::BadToken.new(e)
  end

  def current_user
    User.find(current_user_id)
  end

  def create_token user
    to_jwt user: user.attributes
  end

  def to_jwt payload
    JWT.encode payload, JWT_SECRET, 'HS256'
  end

  def from_jwt token
    JWT.decode token, JWT_SECRET, true, { algorithm: 'HS256' }
  end
end
