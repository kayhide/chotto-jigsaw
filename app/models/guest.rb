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

  def hostable_difficulties
    super.take(0)
  end

  def playable_difficulties
    super.take(2)
  end

  def accessible_difficulties
    super.take(4)
  end
end
