class Api::BaseError < StandardError
  def status
    raise 'status should be implemented'
  end
end
