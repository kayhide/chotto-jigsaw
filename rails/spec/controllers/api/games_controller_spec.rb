require 'rails_helper'

RSpec.describe Api::GamesController, type: :controller do
  authenticate_user

  let(:puzzle) { create :puzzle, :ready }

  describe "GET #index" do
    context "with puzzle" do
      it "returns a success response" do
        create_list :game, 2, puzzle: puzzle
        get :index, params: { puzzle_id: puzzle.id }
        expect(response).to have_http_status(:success)
      end
    end

    context "with picture" do
      let(:puzzle) { create :puzzle, :with_picture }
      let(:picture) { puzzle.picture_blob.becomes(Picture) }

      it "returns a success response" do
        create_list :game, 2, puzzle: puzzle
        get :index, params: { picture_id: picture.id }
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET #show" do
    let(:game) { create :game, puzzle: puzzle }

    it "returns http success" do
      get :show, params: { id: game.id }
      expect(response).to have_http_status(:success)
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

        it "returns created status and the created item" do
          post :create, params: { puzzle_id: puzzle.id }
          expect(response).to have_http_status(:created)
          body = JSON.parse(response.body)
          expect(body).to include(
            "id" => Game.last.id,
            "puzzle_id" => puzzle.id,
            "progress" => 0.0
          )
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

          it "returns created status and the created item" do
            post :create, params: { puzzle_id: puzzle.id }
            expect(response).to have_http_status(:created)
            body = JSON.parse(response.body)
            expect(body).to include(
              "id" => Game.last.id,
              "puzzle_id" => Puzzle.last.id,
              "progress" => 0.0
            )
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
        it "retuns an error" do
          post :create, params: params
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  describe "GET #update" do
    let(:game) { create :game, puzzle: puzzle }

    let(:new_attributes) {
      { progress: 0.75 }
    }

    context "with valid params" do
      it "returns the updated item" do
        patch :update, params: { id: game.id, game: new_attributes }
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body.keys).to match_array %w(
          id picture_id puzzle_id is_ready progress shuffled_at created_at updated_at
        )
      end

      it "updates attributes" do
        expect {
          patch :update, params: { id: game.id, game: new_attributes }
        }.to change { game.reload.attributes }
        expect(game.progress).to eq 0.75
      end
    end

    context "with invalid params" do
      it "returns error" do
        patch :update, params: { id: game.id, game: { progress: nil } }
        res = JSON.parse response.body
        expect(res["error_message"]).to be_present
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:game) { create :game, puzzle: puzzle }

    it "destroys the requested game" do
      expect {
        delete :destroy, params: { id: game.id }
      }.to change(Game, :count).by(-1)
    end

    it "returns no_content" do
      delete :destroy, params: { id: game.id }
      expect(response).to have_http_status(:no_content)
    end
  end

end
