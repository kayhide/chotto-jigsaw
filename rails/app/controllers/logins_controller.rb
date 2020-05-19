class LoginsController < ApplicationController
  def show
    @login = Login.new
  end

  def create
    @login = Login.new(login_params)
    login! @login
  end

  def destroy
    logout!
  end

  private

  def login_params
    params.require(:login).permit(:email)
  end
end
