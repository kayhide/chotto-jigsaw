require 'rails_helper'

RSpec.describe Games::StandaloneController, type: :controller do

  describe "GET #show" do
    let(:puzzle) { create :puzzle, :ready }

    it "returns http success" do
      get :show, params: { puzzle_id: puzzle.id }
      expect(response).to have_http_status(:success)
    end
  end
end
