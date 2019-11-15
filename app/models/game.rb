class Game < ApplicationRecord
  belongs_to :puzzle
  has_many :commands, dependent: :destroy
  has_many :merge_commands
  has_many :transform_commands
  has_many :translate_commands
  has_many :rotate_commands

  def ready?
    shuffled_at?
  end
end
