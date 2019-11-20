class TransformCommand < Command
  include PrefixAttribute

  prefix_attribute :transform, :position_x
  prefix_attribute :transform, :position_y
  prefix_attribute :transform, :rotation

  validates :position_x, presence: true
  validates :position_y, presence: true
  validates :rotation, presence: true

  def command_attributes
    super.merge(position_x: position_x, position_y: position_y, rotation: rotation)
  end

  def position
    Vector[position_x, position_y]
  end

  def position= v
    self.position_x = v[0]
    self.position_y = v[1]
  end

  def self.apply cmds
    base = TransformCommand.new position: Vector[0, 0], rotation: 0

    cmds.reduce(base) do |acc, cmd|
      cmd.from acc
      cmd
    end
  end
end
