require 'rails_helper'

RSpec.describe SetupJob, type: :job do
  describe '#perform' do
    let(:puzzle) { create :puzzle }
    let(:file) { fixture_path.join('pictures/mountain.jpg') }

    before do
      perform_enqueued_jobs do
        puzzle.picture.attach(io: file.open, filename: file.basename)
      end
      puzzle.reload
    end

    it 'creates content' do
      subject.perform puzzle, 3
      expect(puzzle.pieces_count).to eq 187
      expect(puzzle.difficulty).to eq "normal"
      expect(puzzle.linear_measure).to eq 25.337663616004566
    end
  end
end
