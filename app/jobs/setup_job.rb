class SetupJob < ApplicationJob
  class NotAnalyzedError < StandardError; end

  retry_on NotAnalyzedError
  queue_as :default

  def perform puzzle, difficulty_level
    verify_picture! puzzle

    cutter = Jigsaw::Cutter.create :standard, :grid
    cutter.width = puzzle.picture.metadata["width"]
    cutter.height = puzzle.picture.metadata["height"]
    cutter.fluctuation = 0.2
    cutter.irregularity = 0.05

    count = suggested_count difficulty_level
    aspect_ratio = cutter.width.to_f / cutter.height.to_f
    cutter.nx = Math.sqrt(count * aspect_ratio).floor
    cutter.ny = Math.sqrt(count / aspect_ratio).floor

    Tempfile.open("chotto-zigsaw-") do |f|
      Marshal.dump(cutter.cut, f)
      f.close
      puzzle.content.attach(
        io: f.open,
        filename: 'content',
        content_type: 'application/octet-stream',
        identify: false
      )
    end

    puzzle.update!(
      pieces_count: cutter.count,
      difficulty: specify_difficulty(cutter.count),
      linear_measure: cutter.linear_measure
    )
  end

  def verify_picture! puzzle
    raise NotAnalyzedError unless puzzle.picture.analyzed?
  end

  def suggested_count difficulty_level
    Puzzle::DIFFICULTY_THRESHOLDS.values[difficulty_level.to_i - 1]
  end

  def specify_difficulty count
    Puzzle::DIFFICULTY_THRESHOLDS.find { |d, n| n.nil? || count <= n.to_i }.first
  end
end
