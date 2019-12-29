class Public::PuzzlesController < ApplicationController
  def index
    @puzzles =
      Puzzle
      .with_attached_picture
      .order(id: :desc)
      .take(200)
      .filter(&:ready?)
  end
end
