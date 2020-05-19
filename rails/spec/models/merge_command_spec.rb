require 'rails_helper'

RSpec.describe MergeCommand, type: :model do
  describe "attributes" do
    it "works" do
      subject.mergee_id = 3
      expect(subject.mergee_id).to eq 3
    end
  end
end
