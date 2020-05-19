class Puzzle < ApplicationRecord
  belongs_to :user
  has_many :games, dependent: :destroy
  has_one_attached :picture, dependent: false
  has_one_attached :content

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
  }.with_indifferent_access

  scope :order_by_difficulty, -> () {
    order(
      Arel.sql(
        [
          'CASE',
          * DIFFICULTIES.map.with_index { |d, i|
            "WHEN difficulty='#{d}' THEN #{i}"
          },
          'END'
        ].join(' ')
      )
    )
  }

  def ready?
    picture.attached? && picture.analyzed? && content.attached?
  end

  def load_content!
    @pieces = Marshal.load content.download
  end

  def width
    picture.metadata["width"]
  end

  def height
    picture.metadata["height"]
  end

  def suggested_count
    Puzzle::DIFFICULTY_THRESHOLDS[difficulty]
  end
end
