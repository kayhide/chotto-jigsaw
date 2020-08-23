class SetupJob < ApplicationJob
  class NotAnalyzedError < StandardError; end

  retry_on NotAnalyzedError
  queue_as :default

  def perform puzzle
    verify_picture! puzzle

    cutter = Jigsaw::Cutter.create :standard, :grid
    cutter.width = puzzle.picture.metadata["width"]
    cutter.height = puzzle.picture.metadata["height"]
    cutter.fluctuation = 0.2
    cutter.irregularity = 0.05

    count = puzzle.suggested_count
    aspect_ratio = cutter.width.to_f / cutter.height.to_f
    cutter.nx = Math.sqrt(count * aspect_ratio).floor
    cutter.ny = Math.sqrt(count / aspect_ratio).floor

    Tempfile.open("chotto-jigsaw-") do |f|
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
      linear_measure: cutter.linear_measure,
      boundary: Rectangle.new(0.0, 0.0, cutter.width.to_f, cutter.height.to_f)
    )
  end

  def verify_picture! puzzle
    raise NotAnalyzedError unless puzzle.picture.analyzed?
  end
end
