class Command < ApplicationRecord
  belongs_to :user
  belongs_to :game

  validates :piece_id, presence: true
end
