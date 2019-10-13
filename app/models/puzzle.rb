class Puzzle < ApplicationRecord
  belongs_to :user
  has_one_attached :picture
  has_one_attached :content

  attr_accessor :difficulty_level
  attr_reader :pieces

  DIFFICULTIES = %w(trivial easy normal hard extreme lunatic)
  enum difficulty: DIFFICULTIES.map { |x| [x, x] }.to_h

  DIFFICULTY_THRESHOLDS = {
    trivial: 50,
    easy: 100,
    normal: 200,
    hard: 500,
    extreme: 1000,
    lunatic: nil
  }

  def ready?
    picture.attached? && picture.analyzed? && content.attached?
  end

  def load_content!
    @pieces = Marshal.load content.download
  end
end
