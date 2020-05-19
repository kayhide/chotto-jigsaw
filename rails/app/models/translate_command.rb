class TranslateCommand < TransformCommand
  attribute :delta_x, :float
  attribute :delta_y, :float

  validates :delta_x, presence: true
  validates :delta_y, presence: true

  def delta
    Vector[delta_x, delta_y]
  end

  def delta= v
    self.delta_x = v[0]
    self.delta_y = v[1]
  end

  def matrix
    [
      Matrix[
        [1, 0, delta[0]],
        [0, 1, delta[1]],
        [0, 0, 1]
      ]
    ].inject(:*)
  end

  def from src
    self.position = src.position + delta
    self.rotation = src.rotation
  end
end
