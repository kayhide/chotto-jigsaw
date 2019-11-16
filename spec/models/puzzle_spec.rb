require 'rails_helper'

RSpec.describe Puzzle, type: :model do
  describe "scope with_picture_of" do
    let(:puzzle) { create :puzzle, :with_picture }
    it "queries puzzles" do
      picture = puzzle.picture_blob
      expect(Puzzle.with_picture_of(picture)).to eq [puzzle]
    end
  end
end
