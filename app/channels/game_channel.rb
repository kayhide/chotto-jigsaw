class GameChannel < ApplicationCable::Channel
  COMMIT_BATCH_SIZE = 200

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

  def request_content data
    game.reload
    if game.puzzle.ready?
      game.puzzle.load_content!
      content = game.puzzle.slice(:pieces, :linear_measure).to_json
      transmit(
        action: :content,
        success: true,
        content: content
      )
    else
      transmit(
        action: :content,
        success: false,
      )
    end
  end

  def request_update data
    game.reload
    if game.shuffled_at?
      commands = game.commands.order(:id)
      if since = data["since"]
        commands = commands.where(created_at: since .. DateTime.current)
      end
      commands.in_batches(of: COMMIT_BATCH_SIZE) do |cmds|
        transmit(
          action: :commit,
          token: nil,
          commands: cmds.map(&:command_attributes)
        )
      end
      transmit(
        action: :update,
        success: true,
      )
    else
      transmit(
        action: :update,
        success: false,
      )
    end
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
