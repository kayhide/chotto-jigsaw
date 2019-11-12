class Public::PuzzlesController < ApplicationController
  def index
    @puzzles = Puzzle.order(id: :desc)
  end
end
