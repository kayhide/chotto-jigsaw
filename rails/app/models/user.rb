class User < ApplicationRecord
  has_secure_password
  has_many :puzzles
  validates :username, presence: true
  validates :email, presence: true

  has_many :user_pictures_attachments, foreign_key: :record_id
  has_many_attached :pictures

  def attributes
    super.except("password_digest")
  end

  def guest?
    false
  end

  def playable_difficulties
    Puzzle::DIFFICULTIES.take(4)
  end

  def hostable_difficulties
    Puzzle::DIFFICULTIES.take(4)
  end

  def accessible_difficulties
    Puzzle::DIFFICULTIES.take(4)
  end

  def is_playable? difficulty
    playable_difficulties.include? difficulty
  end

  def is_hostable? difficulty
    hostable_difficulties.include? difficulty
  end
end
