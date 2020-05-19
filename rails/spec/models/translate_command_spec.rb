require 'rails_helper'

RSpec.describe TranslateCommand, type: :model do
  describe "attributes" do
    it "works" do
      subject.delta_x = 1.2
      subject.delta_y = 0.2
      expect(subject.delta_x).to eq 1.2
      expect(subject.delta_y).to eq 0.2
    end
  end
end
