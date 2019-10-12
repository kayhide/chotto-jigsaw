class ApplicationController < ActionController::Base
  include Authenticator
  helper_method :current_user, :current_user_id
end
