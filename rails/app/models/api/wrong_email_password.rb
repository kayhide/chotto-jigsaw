class Api::WrongEmailPassword < Api::BaseError
  def status
    :not_found
  end

  def message
    "Wrong Email and/or Password"
  end
end
