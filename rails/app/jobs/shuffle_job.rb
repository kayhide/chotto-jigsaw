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
    scope = game.commands
    commands = puzzle.pieces.map do |piece|
      [
        scope.build.becomes(RotateCommand).tap do |cmd|
          cmd.attributes = {
            user: user,
            piece_id: piece.number,
            pivot: piece.center,
            delta_degree: Random.rand * 360 - 180
          }
        end,
        scope.build.becomes(TranslateCommand).tap do |cmd|
          cmd.attributes = {
            user: user,
            piece_id: piece.number,
            delta: Vector[Random.rand - 0.5, Random.rand - 0.5] * s + c - piece.center
          }
        end
      ].tap(&TransformCommand.method(:apply))
    end.inject(:+)

    commands.each(&:save!)

    game.touch :shuffled_at
  end

  def verify_puzzle! game
    raise NotReadyError unless game.puzzle.ready?
  end
end
