require 'rails_helper'

RSpec.describe LoginsController, type: :controller do

  describe "GET #show" do
    it "returns http success" do
      get :show
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    context "with exisiting user" do
      let!(:user) { create :user }

      it "redirects to root" do
        post :create, params: { login: { email: user.email } }
        expect(response).to redirect_to(:root)
      end

      it "sets current_user" do
        expect {
          post :create, params: { login: { email: user.email } }
        }.to change(controller, :current_user).to(user)
      end
    end

    context "with non-exisiting user" do
      it "returns a success response (renders 'show' template)" do
        post :create, params: { login: { email: "non-exisiting@chotto-jigsaw.test" } }
        expect(response).to be_successful
      end
    end
  end

end
