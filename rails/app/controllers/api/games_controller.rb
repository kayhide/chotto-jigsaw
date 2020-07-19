class Api::GamesController < ApiController
  before_action :set_game, only: [:show, :update, :destroy]
  before_action :set_puzzle
  before_action :set_picture

  def index
    if @picture
      @puzzles = @picture.puzzles.order_by_difficulty.limit(20)
      @games = Game.where(id: @puzzles.map(&:game_ids).flatten).order(updated_at: :desc)
    else
      @games = (@puzzle ? @puzzle.games : Game).order(id: :desc)
    end
    render json: @games.map(&:attributes)
  end

  def show
    render json: @game.attributes
  end

  def create
    unless @puzzle
      difficulty = params.require(:puzzle).require(:difficulty)
      @puzzle =
        @picture.puzzles
        .order(id: :desc)
        .find_by(user: current_user, difficulty: difficulty)
    end
    unless @puzzle
      @puzzle =
        current_user.puzzles
        .create!(picture: @picture, difficulty: difficulty)
      SetupJob.perform_later(@puzzle)
    end

    @game = Game.create!(puzzle: @puzzle)
    ShuffleJob.perform_later(@game)
    render json: @game.attributes, status: :created
  end

  def update
    @game.update! game_params
    render json: @game.attributes
  end

  def destroy
    @game.destroy!
  end

  private

  def set_game
    @game = Game.find(params[:id])
  end

  def game_params
    params.require(:game).permit(:progress)
  end

  def set_puzzle
    @puzzle = @game&.puzzle || Puzzle.find_by(id: params[:puzzle_id])
  end

  def set_picture
    @picture = @puzzle&.picture_blob&.becomes(Picture) || Picture.find_by(id: params[:picture_id])
  end
end
