class MergeCommand < Command
  attribute :mergee_id, :integer

  def command_attributes
    super.merge(mergee_id: mergee_id)
  end
end
