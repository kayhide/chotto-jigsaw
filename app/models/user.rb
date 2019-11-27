class User < ApplicationRecord
  has_many :puzzles
  validates :username, presence: true
  validates :email, presence: true
  has_many_attached :pictures

  def guest?
    false
  end

  def available_difficulties
    Puzzle::DIFFICULTIES.take(4)
  end

  def accessible_difficulties
    Puzzle::DIFFICULTIES.take(5)
  end
end
