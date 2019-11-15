class GameChannel < ApplicationCable::Channel
  def subscribed
    stream_for game
    @connection_token = generate_connection_token

    transmit action: :init, token: @connection_token
  end

  def unsubscribed
  end

  def commit data
    commands = data["commands"].map do |x|
      game.commands.create!(x.merge(user: current_user))
    end
    broadcast_to(
      game,
      action: :commit,
      token: @connection_token,
      commands: commands.map(&:command_attributes)
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

  def report_progress data
    game.update progress: data["progress"]
  end

  private

  def game
    @game ||= Game.find(params[:game_id])
  end

  def generate_connection_token
    SecureRandom.hex(36)
  end
end
