class Games::StandaloneController < GamesController
  layout 'playboard', only: :show

  def show
    @puzzle.load_content!
    super
  end

  private

  def set_game
    @standalone = true
  end
end
