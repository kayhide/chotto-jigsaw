class PuzzlesController < ApplicationController
  before_action :authenticate!
  before_action :set_puzzle, only: [:show, :edit, :update, :destroy, :row]
  before_action :set_picture, only: [:show, :create]

  def index
    @puzzles = Puzzle.all
  end

  def show
    @puzzle.load_content!
  end

  def new
    @puzzle = Puzzle.new
  end

  def create
    @puzzle = Puzzle.new(puzzle_params)
    @puzzle.user = current_user

    if @picture
      @puzzle.picture = @picture
    end
    if @puzzle.picture.attached? && @puzzle.save
      SetupJob.perform_later @puzzle
      respond_to do |format|
        format.js
        format.html { redirect_to [:puzzles], notice: 'Puzzle was successfully created.' }
      end
    else
      respond_to do |format|
        format.js
        format.html { render :new }
      end
    end
  end

  def destroy
    @puzzle.destroy
    redirect_to [:puzzles], notice: 'Puzzle was successfully destroyed.'
  end

  def row
    render partial: "puzzles/row", locals: { puzzle: @puzzle }
  end

  private

  def set_puzzle
    @puzzle = Puzzle.find(params[:id] || params[:puzzle_id])
  end

  def set_picture
    @picture = @puzzle&.picture_blob&.becomes(Picture) || params[:picture_id] && Picture.find(params[:picture_id])
  end

  def puzzle_params
    params.require(:puzzle).permit(:picture, :difficulty)
  end
end
