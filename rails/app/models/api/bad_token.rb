class Api::BadToken < Api::BaseError
  def status
    :unauthorized
  end

  def message
    ["Bad token", cause&.message].compact.join(": ")
  end
end
