require 'rails_helper'

RSpec.describe User, type: :model do
  describe "#guest?" do
    it "returns false" do
      expect(subject.guest?).to eq false
    end
  end
end
