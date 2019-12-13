class Game < ApplicationRecord
  include FireRecord::Collection

  belongs_to :puzzle
  has_many_docs :commands
  # has_many :commands, dependent: :destroy
  # has_many :merge_commands
  # has_many :transform_commands
  # has_many :translate_commands
  # has_many :rotate_commands

  scope :not_started, -> () { where(progress: 0.0) }
  scope :started, -> () { where.not(progress: 0.0) }
  scope :not_finished, -> () { where.not(progress: 1.0) }
  scope :finished, -> () { where(progress: 1.0) }
  scope :active, -> () { started.not_finished }

  def ready?
    shuffled_at?
  end
end
