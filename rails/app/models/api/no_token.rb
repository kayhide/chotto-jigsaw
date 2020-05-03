class Api::NoToken < Api::BaseError
  def status
    :unauthorized
  end

  def message
    "No token"
  end
end
