require 'rails_helper'

RSpec.describe RotateCommand, type: :model do
  describe "attributes" do
    it "works" do
      subject.pivot_x = 14.3
      subject.pivot_y = 24.2
      subject.delta_degree = 2.11
      expect(subject.pivot_x).to eq 14.3
      expect(subject.pivot_y).to eq 24.2
      expect(subject.delta_degree).to eq 2.11
    end
  end
end
