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

end
