require 'rails_helper'

RSpec.describe SetupJob, type: :job do
  describe '#perform' do
    let(:puzzle) { create :puzzle, :with_picture, difficulty: "normal" }

    it 'creates content' do
      subject.perform puzzle
      expect(puzzle.pieces_count).to eq 187
      expect(puzzle.difficulty).to eq "normal"
      expect(puzzle.linear_measure).to eq 25.337663616004566
    end
  end
end
