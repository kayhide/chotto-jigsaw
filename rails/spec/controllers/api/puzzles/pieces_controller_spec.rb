require 'rails_helper'

RSpec.describe Api::Puzzles::PiecesController, type: :controller do
  authenticate_user

  let(:puzzle) { create :puzzle, :ready }

  describe "GET #index" do
    it "returns a success response" do
      get :index, params: { puzzle_id: puzzle.id }
      expect(response).to have_http_status(:success)
      body = JSON.parse response.body
      expect(body.count).to eq 40
      expect(body.map(&:keys)).to all match_array %w(
        neighbors number points
      )
    end
  end
end
