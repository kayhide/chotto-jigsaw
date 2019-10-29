class ShuffleJob < ApplicationJob
  queue_as :default

  def perform game
    puzzle = game.puzzle
    user = puzzle.user

    puzzle.load_content!

    s = [puzzle.width, puzzle.height].max * 2
    puzzle.pieces.each do |piece|
      TransformCommand.apply!(
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
          delta: Vector[Random.rand, Random.rand] * s - piece.center
        )
      )
    end

    game.touch :shuffled_at
  end
end
