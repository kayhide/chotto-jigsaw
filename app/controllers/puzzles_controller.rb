class PuzzlesController < ApplicationController
  before_action :authenticate!
  before_action :set_puzzle, only: [:show, :edit, :update, :destroy]

  def index
    @puzzles = Puzzle.all
  end

  def show
    @puzzle.load_content!
  end

  def new
    @puzzle = Puzzle.new difficulty_level: 2
  end

  def create
    @puzzle = Puzzle.new(puzzle_params)
    @puzzle.user = current_user

    if @puzzle.picture.attached? && @puzzle.save
      SetupJob.perform_later @puzzle, @puzzle.difficulty_level
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
    params.require(:puzzle).permit(:picture, :difficulty_level)
  end
end