class MergeCommand < Command
  include PrefixAttribute

  prefix_attribute :merge, :mergee_id
end
