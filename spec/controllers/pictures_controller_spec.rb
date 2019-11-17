require 'rails_helper'

RSpec.describe PicturesController, type: :controller do
  authenticate_user

  describe "GET #index" do
    it "returns http success" do
      puzzle = create :puzzle, :with_picture, user: current_user
      current_user.pictures.attach puzzle.picture_blob
      get :index, params: {}
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    it "returns http success" do
      puzzle = create :puzzle, :with_picture, user: current_user
      current_user.pictures.attach puzzle.picture_blob
      get :show, params: { id: puzzle.picture_blob.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    let(:file) { fixture_path.join('pictures/mountain.jpg') }
    let(:file_param) { fixture_file_upload file }
    let(:valid_params) {
      {
        file: file_param
      }
    }

    context "with valid params" do
      it "attaches a new picture to current_user" do
        expect {
          post :create, params: { picture: valid_params }
        }.to change(current_user.pictures, :count).by(1)
      end

      it "redirects to the pictures lit" do
        post :create, params: { picture: valid_params }
        expect(response).to redirect_to([:pictures])
      end
    end
  end
end
