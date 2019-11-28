class User < ApplicationRecord
  has_many :puzzles
  validates :username, presence: true
  validates :email, presence: true
  has_many_attached :pictures

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
