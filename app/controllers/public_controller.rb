class PublicController < ApplicationController
  def index
    ids =
      Game
        .select(:id, :puzzle_id)
        .group(:puzzle_id)
        .maximum(:id)
        .values
    @games = Game.where(id: ids)
  end
end
