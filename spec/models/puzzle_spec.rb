require 'rails_helper'

RSpec.describe Puzzle, type: :model do
  describe "#setup!" do
    subject { create :puzzle }
    let(:file) { fixture_path.join('pictures/mountain.jpg') }

    before do
      perform_enqueued_jobs do
        subject.picture.attach(io: File.open(file), filename: file.basename)
      end
      subject.reload
    end

    it "creates puzzle" do
      subject.setup! 200
      expect(subject.linear_measure).to eq 29.70201941604025
      expect(subject.pieces_count).to eq 187
      expect(subject.difficulty).to eq "normal"
    end
  end
end
