class Api::GamesController < ApiController
  before_action :authenticate!, only: [:create]
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
    @games = @games.includes(puzzle: :puzzle_picture_attachment)
    render json: @games.map(&method(:index_attributes))
  end

  def show
    add_firebase_token_response_header @game
    render json: show_attributes(@game)
  end

  def create
    unless @puzzle
      difficulty = params.require(:difficulty)
      @puzzle =
        current_user.puzzles
        .create!(picture: @picture.blob, difficulty: difficulty)
      SetupJob.perform_later(@puzzle)
    end

    @game = Game.create!(puzzle: @puzzle)
    ShuffleJob.perform_later(@game)
    render json: index_attributes(@game), status: :created
  end

  def update
    @game.update! game_params
    render json: index_attributes(@game)
  end

  def destroy
    @game.destroy!
  end

  private

  def set_game
    @game = Game.find(params[:id])
  end

  def game_params
    params.permit(:progress)
  end

  def set_puzzle
    @puzzle = @game&.puzzle ||
      (params.key?(:puzzle_id) && Puzzle.find_by(id: params[:puzzle_id]))
  end

  def set_picture
    @picture =
      (@puzzle && UserPicturesAttachment.find_by(record_id: @puzzle.user_id, blob_id: @puzzle.picture_attachment&.blob_id)) ||
      (params.key?(:picture_id) && UserPicturesAttachment.find_by(id: params[:picture_id]))
  end

  # TODO Improve inefficient picture_id query.
  def index_attributes game
    puzzle = game.puzzle
    game.attributes.merge(
      "picture_id" => UserPicturesAttachment.find_by(blob_id: puzzle.puzzle_picture_attachment&.blob_id)&.id,
      "is_ready" => game.ready?,
      "puzzle" =>
        puzzle.attributes
        .merge(
          picture_url: rails_blob_url(puzzle.picture),
          picture_thumbnail_url: rails_representation_url(puzzle.picture.variant(resize_to_fill: [300, 300]).processed)
        )
    )
  end

  def show_attributes game
    index_attributes game
  end
end
