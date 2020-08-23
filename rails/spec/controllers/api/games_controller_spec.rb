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
        body = JSON.parse response.body
        expect(body.map(&:keys)).to all match_array %w(
          id picture_id puzzle_id puzzle is_ready progress shuffled_at created_at updated_at
        )
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
      body = JSON.parse response.body
      expect(body.keys).to match_array %w(
        id picture_id puzzle_id puzzle is_ready progress shuffled_at created_at updated_at
      )
      expect(body["puzzle"].keys).to match_array %w(
        id user_id  pieces_count linear_measure difficulty boundary picture_url picture_thumbnail_url created_at updated_at
      )
      expect(body["puzzle"]["boundary"].keys).to match_array %w(
        x y width height
      )
    end

    it "adds firebase token to the response header" do
      get :show, params: { id: game.id }
      expect(response.header["Firebase-Token"]).to be_present
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
      let(:picture) {
        current_user.pictures.attach puzzle.picture_blob
        current_user.user_pictures_attachments.last
      }

      context "with valid params" do
        let(:params) {
          { picture_id: picture.id, difficulty: "trivial" }
        }

        it "creates a new puzzle and creates a new Game" do
          expect {
            expect {
              post :create, params: params
            }.to change(Puzzle, :count).by(1)
          }.to change(Game, :count).by(1)
        end
      end

      context "with invalid params" do
        let(:params) {
          { picture_id: picture.id, difficulty: "invalid" }
        }

        it "retuns an error" do
          post :create, params: params
          expect(response).to have_http_status(:unprocessable_entity)
          body = JSON.parse response.body
          expect(body["error_message"]).to include "not a valid difficulty"
        end
      end
    end
  end

  describe "PUT #update" do
    let(:game) { create :game, puzzle: puzzle }

    let(:new_attributes) {
      { progress: 0.75 }
    }

    context "with valid params" do
      it "returns the updated item" do
        put :update, params: { id: game.id, **new_attributes }
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body.keys).to match_array %w(
          id picture_id puzzle_id puzzle is_ready progress shuffled_at created_at updated_at
        )
      end

      it "updates attributes" do
        expect {
          put :update, params: { id: game.id, **new_attributes }
        }.to change { game.reload.attributes }
        expect(game.progress).to eq 0.75
      end
    end

    context "with invalid params" do
      it "returns error" do
        put :update, params: { id: game.id, progress: nil }
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
