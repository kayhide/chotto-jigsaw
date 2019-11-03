require 'rails_helper'

RSpec.describe ShuffleJob, type: :job do
  describe '#perform' do
    let(:puzzle) { create :puzzle, :ready }
    let(:game) { create :game, puzzle: puzzle }


    it 'creates commands' do
      expect {
        subject.perform game
      }.to change(Command, :count).by(80)
    end

    it 'scatters pieces in a specific area' do
      subject.perform game

      pieces = puzzle.pieces
      positions = pieces.map { |p| Vector[*p.center.to_a, 1] }
      game.transform_commands.each do |cmd|
        positions[cmd.piece_id] = cmd.matrix * positions[cmd.piece_id]
      end

      expect(puzzle.width).to eq 300
      expect(puzzle.height).to eq 200
      expect(positions.map { |p| p[0] }).to all be_between(0, 600)
      expect(positions.map { |p| p[1] }).to all be_between(0, 600)
    end
  end
end