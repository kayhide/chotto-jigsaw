class GameChannel < ApplicationCable::Channel
  def subscribed
    game = Game.find(params[:game_id])
    stream_for game
    @connection_token = generate_connection_token
    logger.info @connection_token
    transmit action: :init, token: @connection_token
  end

  def unsubscribed
  end

  def commit data
    game = Game.find(params[:game_id])
    broadcast_to game, action: :commit, token: @connection_token, commands: data["commands"]
  end

  private

  def generate_connection_token
    SecureRandom.hex(36)
  end
end
