class ApiController < ActionController::API
  include Authenticator

  rescue_from ApiError, with: :handle_api_error
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :handle_unprocessable_entity
  rescue_from ActiveRecord::InvalidForeignKey, with: :handle_invalid_foreign_key
  rescue_from ActionController::ParameterMissing, with: :handle_unprocessable_entity
  rescue_from ActionController::InvalidAuthenticityToken, with: :handle_invalid_authenticity_token
  rescue_from Api::WrongEmailPassword, with: :handle_api_error
  rescue_from Api::BadToken, with: :handle_api_error
  rescue_from Api::NoToken, with: :handle_api_error

  def handle_api_error e
    render json: { error_message: e.message }, status: e.status
  end

  def handle_not_found e
    render json: { error_message: e.message }, status: :not_found
  end

  def handle_unprocessable_entity e
    render json: { error_message: e.message }, status: :unprocessable_entity
  end

  def handle_invalid_foreign_key e
    msg = "Cannot update or delete because some other resources are refering to it"
    render json: { error_message: msg }, status: :unprocessable_entity
  end

  def handle_invalid_authenticity_token e
    msg = "Authenticity token is missing or invalid"
    render json: { error_message: msg }, status: :unprocessable_entity
  end
end
