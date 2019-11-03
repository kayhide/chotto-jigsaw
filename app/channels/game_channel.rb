class GameChannel < ApplicationCable::Channel
  def subscribed
    stream_for game
    @connection_token = generate_connection_token
    logger.info @connection_token

    transmit action: :init, token: @connection_token
  end

  def unsubscribed
  end

  def commit data
    broadcast_to(
      game,
      action: :commit,
      token: @connection_token,
      commands: data["commands"]
    )
  end

  def request_update data
    commands = game.commands.order(:id)
    if since = data["since"]
      commands = commands.where(created_at: since .. DateTime.current)
    end
    transmit(
      action: :commit,
      token: nil,
      commands: commands.map(&:command_attributes)
    )
  end

  private

  def game
    Game.find(params[:game_id])
  end

  def generate_connection_token
    SecureRandom.hex(36)
  end
end
