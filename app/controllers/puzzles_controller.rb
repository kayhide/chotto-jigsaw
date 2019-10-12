class PuzzlesController < ApplicationController
  before_action :authenticate!
  before_action :set_puzzle, only: [:show, :edit, :update, :destroy]

  def index
    @puzzles = Puzzle.all
  end

  def show
  end

  def new
    @puzzle = Puzzle.new
  end

  def create
    @puzzle = Puzzle.new(puzzle_params)
    @puzzle.user = current_user

    if @puzzle.save
      redirect_to [:puzzles], notice: 'Puzzle was successfully created.'
    else
      render :new
    end
  end

  def destroy
    @puzzle.destroy
    redirect_to [:puzzles], notice: 'Puzzle was successfully destroyed.'
  end

  private

  def set_puzzle
    @puzzle = Puzzle.find(params[:id])
  end

  def puzzle_params
    params.require(:puzzle).permit(:image)
  end
end
