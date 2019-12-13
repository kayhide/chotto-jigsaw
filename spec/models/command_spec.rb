require 'rails_helper'

RSpec.describe Command, type: :model do
  let(:game) { create :game }

  it "works" do
    rotate = game.commands.build.becomes(RotateCommand)
    puts rotate.command_attributes
    puts FireRecord.client
    puts Command.attribute_types
    puts FireRecord.client.doc("users/1").get
    puts Command.new

  end
end
