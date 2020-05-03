class ApplicationController < ActionController::Base
  include WebAuthenticator
  helper_method :current_user, :current_user_id
end
