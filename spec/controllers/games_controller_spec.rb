require 'rails_helper'

RSpec.describe GamesController, type: :controller do
  authenticate_user

  let(:puzzle) { create :puzzle }

  describe "GET #index" do
    context "with puzzle" do
      it "returns a success response" do
        create_list :game, 2, puzzle: puzzle
        get :index, params: { puzzle_id: puzzle.id }
        expect(response).to be_successful
      end
    end

    context "with picture" do
      let(:puzzle) { create :puzzle, :with_picture }
      let(:picture) { puzzle.picture_blob.becomes(Picture) }

      it "returns a success response" do
        create_list :game, 2, puzzle: puzzle
        get :index, params: { picture_id: picture.id }
        expect(response).to be_successful
      end
    end
  end

  describe "GET #show" do
    let(:puzzle) { create :puzzle, :ready }

    it "returns a success response" do
      game = create :game, puzzle: puzzle
      get :show, params: { id: game.id }
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "under puzzle" do
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

    context "under picture" do
      let!(:puzzle) { create :puzzle, :with_picture, user: current_user, difficulty: "trivial" }
      let(:picture) { puzzle.picture_blob.becomes(Picture) }

      context "with valid params" do
        let(:params) {
          { picture_id: picture.id, puzzle: { difficulty: "trivial" } }
        }
        context "with existing puzzle" do
          it "reuses the puzzle and create a new Game" do
            expect {
              expect {
                post :create, params: params
              }.not_to change(Puzzle, :count)
            }.to change(Game, :count).by(1)

            expect(Puzzle.last).to eq puzzle
          end

          it "redirects to the created game" do
            post :create, params: params
            expect(response).to redirect_to(Game.last)
          end
        end

        context "without existing puzzle" do
          let!(:puzzle) { create :puzzle, :with_picture, user: current_user, difficulty: "easy" }

          before do
            # Puzzle created by another user with the same picture and difficulty
            create :puzzle, picture: picture, difficulty: "trivial"
          end

          it "creates a new puzzle and creates a new Game" do
            expect {
              expect {
                post :create, params: params
              }.to change(Puzzle, :count).by(1)
            }.to change(Game, :count).by(1)
          end
        end
      end

      context "with invalid params" do
        let(:params) {
          { picture_id: picture.id, puzzle: {} }
        }
        fit "redirects to the created game" do
          post :create, params: params
          expect(response).to redirect_to([picture, :games])
        end
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
