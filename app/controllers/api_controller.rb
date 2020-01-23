class ApiController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :handle_record_invalid
  rescue_from ActiveRecord::InvalidForeignKey, with: :handle_record_invalid_foreign_key
  rescue_from ActionController::ParameterMissing, with: :handle_parametter_missing

  def handle_error e
    render json: { error_message: e.message }, status: e.status
  end

  def handle_record_not_found e
    render json: { error_message: e.message }, status: :not_found
  end

  def handle_record_invalid e
    render json: { error_message: e.message }, status: :unprocessable_entity
  end

  def handle_record_invalid_foreign_key e
    render json: { error_message: "Cannot update or delete because some other resources are refering to it" }, status: :unprocessable_entity
  end

  def handle_parametter_missing e
    render json: { error_message: e.message }, status: :unprocessable_entity
  end
end
