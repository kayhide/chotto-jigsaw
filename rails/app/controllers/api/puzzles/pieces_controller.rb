class Api::Puzzles::PiecesController < ApiController
  before_action :set_puzzle

  def index
    @puzzle.load_content!
    render json: @puzzle.pieces
  end

  private

  def set_puzzle
    @puzzle = Puzzle.find(params[:puzzle_id])
  end
end
