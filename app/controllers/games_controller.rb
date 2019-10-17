class GamesController < ApplicationController
  before_action :set_game, only: [:show, :destroy]
  before_action :set_puzzle

  layout 'playboard', only: :show

  def index
    @games = Game.order(id: :desc)
  end

  def show
    @puzzle.load_content!
  end

  def create
    @game = Game.new(puzzle: @puzzle)

    if @game.save
      redirect_to @game, notice: 'Game was successfully created.'
    else
      render :new
    end
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
    @puzzle = @game&.puzzle || Puzzle.find(params[:puzzle_id])
  end
end
