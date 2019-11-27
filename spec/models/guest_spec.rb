require 'rails_helper'

RSpec.describe Guest, type: :model do
  describe "validation" do
    it "invalidates" do
      expect(subject.valid?).to eq false
      expect(subject.errors[:base]).to be_present
    end
  end

  describe "attributes" do
    it "returns fixed attributes" do
      expect(subject.username).to eq "Guest"
      expect(subject.email).to eq "guest"
    end
  end

  describe "#guest?" do
    it "returns true" do
      expect(subject.guest?).to eq true
    end
  end
end
