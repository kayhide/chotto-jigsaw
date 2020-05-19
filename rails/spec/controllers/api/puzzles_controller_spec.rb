require 'rails_helper'

RSpec.describe Api::PuzzlesController, type: :controller do
  authenticate_user

  describe "GET #show" do
    context "with ready puzzle" do
      let(:puzzle) { create :puzzle, :ready }

      it "returns http success" do
        get :show, params: { id: puzzle.id }
        expect(response).to have_http_status(:success)
      end
    end

    context "with non-ready puzzle" do
      let(:puzzle) { create :puzzle }

      it "returns error" do
        get :show, params: { id: puzzle.id }
        expect(response).to have_http_status(:unprocessable_entity)
        res = JSON.parse(response.body)
        expect(res["error_message"]).to be_present
      end
    end
  end
end
