class User < ApplicationRecord
  has_many :puzzles
  validates :username, presence: true
end
