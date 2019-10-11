class PuzzlesController < ApplicationController
  before_action :set_puzzle, only: [:show, :edit, :update, :destroy]

  # GET /puzzles
  def index
    @puzzles = Puzzle.all
  end

  # GET /puzzles/1
  def show
  end

  # GET /puzzles/new
  def new
    @puzzle = Puzzle.new
  end

  # GET /puzzles/1/edit
  def edit
  end

  # POST /puzzles
  def create
    @puzzle = Puzzle.new(puzzle_params)

    if @puzzle.save
      redirect_to @puzzle, notice: 'Puzzle was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /puzzles/1
  def update
    if @puzzle.update(puzzle_params)
      redirect_to @puzzle, notice: 'Puzzle was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /puzzles/1
  def destroy
    @puzzle.destroy
    redirect_to puzzles_url, notice: 'Puzzle was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_puzzle
      @puzzle = Puzzle.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def puzzle_params
      params.require(:puzzle).permit(:user, :linear_measure)
    end
end
