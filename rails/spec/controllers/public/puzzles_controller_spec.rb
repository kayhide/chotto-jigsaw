require 'rails_helper'

RSpec.describe Public::PuzzlesController, type: :controller do

  describe "GET #index" do
    it "returns http success" do
      create_list :puzzle, 2
      get :index
      expect(response).to have_http_status(:success)
    end
  end
end
