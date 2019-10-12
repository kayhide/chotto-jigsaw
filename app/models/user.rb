class User < ApplicationRecord
  has_many :puzzles
  validates :username, presence: true
  validates :email, presence: true
end
