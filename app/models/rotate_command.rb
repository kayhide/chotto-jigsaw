class RotateCommand < TransformCommand
  include PrefixAttribute

  prefix_attribute :rotate, :pivot_x
  prefix_attribute :rotate, :pivot_y
  prefix_attribute :rotate, :delta_degree

  validates :pivot_x, presence: true
  validates :pivot_y, presence: true
  validates :delta_degree, presence: true
end
