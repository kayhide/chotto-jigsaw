class Api::GamesController < ApiController
  before_action :set_game

  def show
    render json: @game.attributes
  end

  def update
    @game.update! game_params
  end

  private

  def set_game
    @game = Game.find(params[:id])
  end

  def game_params
    params.permit(:progress)
  end
end
