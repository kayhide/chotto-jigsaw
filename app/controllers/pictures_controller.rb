class PicturesController < ApplicationController
  before_action :authenticate!
  before_action :set_picture, only: [:show]

  def index
    @pictures = current_user.pictures_blobs.order(id: :desc)
  end

  def show
    @puzzles = Puzzle.with_picture_of(@picture).order(id: :desc)
  end

  private

  def set_picture
    @picture = current_user.pictures_blobs.find(params[:id]).becomes(Picture)
  end
end
