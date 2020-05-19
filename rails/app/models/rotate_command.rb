class RotateCommand < TransformCommand
  attribute :pivot_x, :float
  attribute :pivot_y, :float
  attribute :delta_degree, :float

  validates :pivot_x, presence: true
  validates :pivot_y, presence: true
  validates :delta_degree, presence: true

  def pivot
    Vector[pivot_x, pivot_y]
  end

  def pivot= v
    self.pivot_x = v[0]
    self.pivot_y = v[1]
  end

  def matrix
    rad = delta_degree * Math::PI / 180
    [
      Matrix[
        [1, 0, pivot[0]],
        [0, 1, pivot[1]],
        [0, 0, 1]
      ],
      Matrix[
        [Math.cos(rad), -Math.sin(rad), 1],
        [Math.sin(rad), Math.cos(rad), 1],
        [0, 0, 1]
      ],
      Matrix[
        [1, 0, -pivot[0]],
        [0, 1, -pivot[1]],
        [0, 0, 1]
      ]
    ].inject(:*)
  end

  def from src
    v = matrix * Vector[src.position[0], src.position[1], 1]
    self.position = v
    self.rotation = src.rotation + delta_degree
  end
end
