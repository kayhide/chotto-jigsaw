require 'rails_helper'

RSpec.describe Api::GamesController, type: :controller do
  authenticate_user

  let(:puzzle) { create :puzzle, :ready }

  describe "GET #show" do
    let(:game) { create :game, puzzle: puzzle }

    it "returns http success" do
      get :show, xhr: true, params: { id: game.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #update" do
    let(:game) { create :game, puzzle: puzzle }

    let(:new_attributes) {
      { progress: 0.75 }
    }

    it "returns no_content" do
      patch :update, xhr: true, params: { id: game.id }.merge(new_attributes)
      expect(response).to have_http_status(:no_content)
    end

    it "updates attributes" do
      expect {
        patch :update, xhr: true, params: { id: game.id }.merge(new_attributes)
      }.to change { game.reload.attributes }
      expect(game.progress).to eq 0.75
    end
  end

end
