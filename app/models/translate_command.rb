class TranslateCommand < TransformCommand
  include PrefixAttribute

  prefix_attribute :translate, :delta_x
  prefix_attribute :translate, :delta_y

  validates :delta_x, presence: true
  validates :delta_y, presence: true
end
