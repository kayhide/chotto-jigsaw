class MergeCommand < Command
  attribute :mergee_id, :integer

  def command_attributes
    super.merge(attributes.slice %(mergee_id))
  end
end
