class Games::StandaloneController < GamesController
  layout 'playboard', only: :show

  private

  def set_game
    @standalone = true
  end
end
