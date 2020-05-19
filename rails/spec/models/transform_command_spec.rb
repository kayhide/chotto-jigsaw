require 'rails_helper'

RSpec.describe TransformCommand, type: :model do
  describe "attributes" do
    it "works" do
      subject.position_x = 1.5
      subject.position_y = 4.3
      subject.rotation = 2.9
      expect(subject.position_x).to eq 1.5
      expect(subject.position_y).to eq 4.3
      expect(subject.rotation).to eq 2.9
    end
  end
end
