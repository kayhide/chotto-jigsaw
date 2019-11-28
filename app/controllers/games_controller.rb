class GamesController < ApplicationController
  before_action :authenticate!
  before_action :set_game, only: [:show, :destroy]
  before_action :set_puzzle
  before_action :set_picture

  layout 'playboard', only: :show

  def index
    if @picture
      @puzzles = @picture.puzzles.order_by_difficulty.limit(20)
      @games = Game.where(id: @puzzles.map(&:game_ids).flatten).order(updated_at: :desc)
    else
      @games = (@puzzle ? @puzzle.games : Game).order(id: :desc)
    end
  end

  def show
    cookies.encrypted[:user_id] = current_user_id
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
    redirect_to @game

  rescue
    redirect_to [@picture, :games], alert: 'Failed to create a Game'
  end

  def destroy
    @game.destroy
    redirect_to [@puzzle, :games], notice: 'Game was successfully destroyed.'
  end

  private

  def set_game
    @game = Game.find(params[:id])
  end

  def set_puzzle
    @puzzle = @game&.puzzle || Puzzle.find_by(id: params[:puzzle_id])
  end

  def set_picture
    @picture = @puzzle&.picture_blob&.becomes(Picture) || Picture.find_by(id: params[:picture_id])
  end
end
