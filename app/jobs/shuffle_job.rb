class ShuffleJob < ApplicationJob
  class NotReadyError < StandardError; end

  retry_on NotReadyError
  queue_as :default

  def perform game
    verify_puzzle! game

    puzzle = game.puzzle
    user = puzzle.user

    puzzle.load_content!

    s = [puzzle.width, puzzle.height].max * 2
    c = Vector[puzzle.width, puzzle.height] * 0.5
    commands = puzzle.pieces.map do |piece|
      [
        RotateCommand.new(
          user: user,
          game: game,
          piece_id: piece.number,
          pivot: piece.center,
          delta_degree: Random.rand * 360 - 180
        ),
        TranslateCommand.new(
          user: user,
          game: game,
          piece_id: piece.number,
          delta: Vector[Random.rand - 0.5, Random.rand - 0.5] * s + c - piece.center
        )
      ].tap(&TransformCommand.method(:apply))
    end.inject(:+)

    Command.transaction do
      commands.each(&:save!)
    end

    game.touch :shuffled_at
  end

  def verify_puzzle! game
    raise NotReadyError unless game.puzzle.ready?
  end
end
