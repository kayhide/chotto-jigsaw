class Game < ApplicationRecord
  include FireRecord::Collection

  belongs_to :puzzle
  has_many_docs :commands

  scope :not_started, -> { where(progress: 0.0) }
  scope :started, -> { where.not(progress: 0.0) }
  scope :not_finished, -> { where.not(progress: 1.0) }
  scope :finished, -> { where(progress: 1.0) }
  scope :active, -> { started.not_finished }

  validates :progress, presence: true

  def ready?
    shuffled_at?
  end
end
