module Authenticator
  extend ActiveSupport::Concern

  def authenticate!
    unless current_user
      redirect_to controller: :logins, action: :show
    end
  end

  def current_user
    User.find(current_user_id)
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def current_user_id
    session[:current_user_id]
  end

  def login! login
    if login.validate
      session[:current_user_id] = login.user.id
      redirect_to :root
    else
      session[:current_user_id] = nil
      render :show
    end
  end

  def logout!
    session[:current_user_id] = nil
    redirect_to :root
  end
end
