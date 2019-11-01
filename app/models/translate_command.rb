class TranslateCommand < TransformCommand
  include PrefixAttribute

  prefix_attribute :translate, :delta_x
  prefix_attribute :translate, :delta_y

  validates :delta_x, presence: true
  validates :delta_y, presence: true

  def command_attributes
    super.merge(delta_x: delta_x, delta_y: delta_y)
  end

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
