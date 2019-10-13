require 'rails_helper'

RSpec.describe PuzzlesController, type: :controller do
  authenticate_user

  let(:valid_attributes) {
    {
      picture: picture,
      difficulty_level: 4
    }
  }

  let(:invalid_attributes) {
    {
      picture: nil
    }
  }

  describe "GET #index" do
    it "returns a success response" do
      create :puzzle, user: current_user
      get :index, params: {}
      expect(response).to be_successful
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new, params: {}
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    let(:picture) { fixture_file_upload fixture_path.join('pictures/mountain.jpg') }

    context "with valid params" do
      it "creates a new Puzzle" do
        expect {
          post :create, params: { puzzle: valid_attributes }
        }.to change(Puzzle, :count).by(1)
      end

      it "enqueues SetupJob" do
        assert_enqueued_with job: SetupJob do
          post :create, params: { puzzle: valid_attributes }
        end
      end

      it "redirects to the created puzzle" do
        post :create, params: { puzzle: valid_attributes }
        expect(response).to redirect_to([:puzzles])
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested puzzle" do
      puzzle = create :puzzle, user: current_user
      expect {
        delete :destroy, params: { id: puzzle.id }
      }.to change(Puzzle, :count).by(-1)
    end

    it "redirects to the puzzles list" do
      puzzle = create :puzzle, user: current_user
      delete :destroy, params: { id: puzzle.id }
      expect(response).to redirect_to(puzzles_url)
    end
  end

end
