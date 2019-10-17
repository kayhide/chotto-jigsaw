require 'rails_helper'

RSpec.describe GamesController, type: :controller do
  authenticate_user

  let(:puzzle) { create :puzzle }

  describe "GET #index" do
    it "returns a success response" do
      create_list :game, 2, puzzle: puzzle
      get :index, params: { puzzle_id: puzzle.id }
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      game = create :game, puzzle: puzzle
      get :show, params: { id: game.id }
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Game" do
        expect {
          post :create, params: { puzzle_id: puzzle.id }
        }.to change(Game, :count).by(1)
      end

      it "redirects to the created game" do
        post :create, params: { puzzle_id: puzzle.id }
        expect(response).to redirect_to(Game.last)
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested game" do
      game = create :game, puzzle: puzzle
      expect {
        delete :destroy, params: { id: game.id }
      }.to change(Game, :count).by(-1)
    end

    it "redirects to the games list" do
      game = create :game, puzzle: puzzle
      delete :destroy, params: { id: game.id }
      expect(response).to redirect_to([puzzle, :games])
    end
  end

end
