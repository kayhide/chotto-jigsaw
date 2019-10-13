class Puzzle < ApplicationRecord
  belongs_to :user
  has_one_attached :picture
  has_one_attached :content

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

  def setup! count
    cutter = Jigsaw::Cutter.create :standard, :grid
    cutter.width = picture.metadata["width"]
    cutter.height = picture.metadata["height"]
    cutter.fluctuation = 0.3
    cutter.irregularity = 0.2

    aspect_ratio = cutter.height.to_f / cutter.width.to_f
    cutter.nx = Math.sqrt(count * aspect_ratio).floor
    cutter.ny = Math.sqrt(count / aspect_ratio).floor

    Tempfile.open("chotto-zigsaw-") do |f|
      Marshal.dump(cutter.cut, f)
      f.close
      content.attach(
        io: f.open,
        filename: 'content',
        content_type: 'application/octet-stream',
        identify: false
      )
    end

    self.pieces_count = cutter.nx * cutter.ny
    self.difficulty = specify_difficulty pieces_count
    self.linear_measure = cutter.linear_measure

    save!
  end

  def specify_difficulty count
    DIFFICULTY_THRESHOLDS.find { |d, n| n.nil? || count <= n.to_i }.first
  end
end
