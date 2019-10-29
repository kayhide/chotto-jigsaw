class TransformCommand < Command
  include PrefixAttribute

  prefix_attribute :transform, :position_x
  prefix_attribute :transform, :position_y
  prefix_attribute :transform, :rotation

  validates :position_x, presence: true
  validates :position_y, presence: true
  validates :rotation, presence: true
end
