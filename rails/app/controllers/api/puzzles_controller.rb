class Api::PuzzlesController < ApiController
  before_action :set_puzzle
  before_action :verify_puzzle

  def show
    @puzzle.load_content!
    render json: @puzzle.attributes.merge(pieces: @puzzle.pieces)
  end

  private

  def set_puzzle
    @puzzle = Puzzle.find(params[:id])
  end

  def verify_puzzle
    return if @puzzle.ready?

    raise ApiError.new("Puzzle is not ready", :unprocessable_entity)
  end
end
