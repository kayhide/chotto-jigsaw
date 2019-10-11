require 'rails_helper'

RSpec.describe PuzzlesController, type: :controller do

  let(:valid_attributes) {
    {
      linear_measure: 1.23
    }
  }

  let(:invalid_attributes) {
    {
      user_id: nil
    }
  }

  describe "GET #index" do
    it "returns a success response" do
      Puzzle.create! valid_attributes
      get :index, params: {}
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      puzzle = Puzzle.create! valid_attributes
      get :show, params: { id: puzzle.id }
      expect(response).to be_successful
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new, params: {}
      expect(response).to be_successful
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      puzzle = Puzzle.create! valid_attributes
      get :edit, params: { id: puzzle.id }
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Puzzle" do
        expect {
          post :create, params: {puzzle: valid_attributes}
        }.to change(Puzzle, :count).by(1)
      end

      it "redirects to the created puzzle" do
        post :create, params: { puzzle: valid_attributes }
        expect(response).to redirect_to(Puzzle.last)
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        {
          linear_measure: 3.45
        }
      }

      it "updates the requested puzzle" do
        puzzle = Puzzle.create! valid_attributes
        expect {
          put :update, params: { id: puzzle.id, puzzle: new_attributes }
        }.to change { puzzle.reload.linear_measure }.to(3.45)
      end

      it "redirects to the puzzle" do
        puzzle = Puzzle.create! valid_attributes
        put :update, params: { id: puzzle.id, puzzle: valid_attributes }
        expect(response).to redirect_to(puzzle)
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested puzzle" do
      puzzle = Puzzle.create! valid_attributes
      expect {
        delete :destroy, params: { id: puzzle.id }
      }.to change(Puzzle, :count).by(-1)
    end

    it "redirects to the puzzles list" do
      puzzle = Puzzle.create! valid_attributes
      delete :destroy, params: { id: puzzle.id }
      expect(response).to redirect_to(puzzles_url)
    end
  end

end
