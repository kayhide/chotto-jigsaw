class MergeCommand < Command
  include PrefixAttribute

  prefix_attribute :merge, :mergee_id

  def command_attributes
    super.merge(mergee_id: mergee_id)
  end
end
