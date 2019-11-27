class Guest < User
  validate do |guest|
    guest.errors[:base] << "Guest can not be valid"
  end

  def username
    "Guest"
  end

  def email
    "guest"
  end

  def guest?
    true
  end

  def available_difficulties
    super.take(3)
  end

  def accessible_difficulties
    super.take(3)
  end
end
