class Api::AuthController < ApiController
  before_action :authenticate!, except: :create

  def show
    user = User.find current_user_id
    render json: user
  end

  def create
    email = params.require :email
    password = params.require :password
    user = User.find_by! email: email
    raise ActiveRecord::RecordNotFound unless user.authenticate(password)

    token = create_token user
    render json: { token: token }.merge(user: user.attributes)

  rescue ActiveRecord::RecordNotFound
    raise Api::WrongEmailPassword
  end
end
