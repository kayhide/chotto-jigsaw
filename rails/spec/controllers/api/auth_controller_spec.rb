require 'rails_helper'

RSpec.describe Api::AuthController, type: :controller do
  describe "GET #show" do
    context "with authenticated user" do
      authenticate_user

      it "renders a JSON response with a user" do
        get :show
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match %r(application/json)
        body = JSON.parse(response.body)
        expect(body["id"]).to eq @current_user.id
      end

      it "includes user attributes" do
        get :show
        body = JSON.parse(response.body)
        expect(body.keys)
          .to match %w(id username email created_at updated_at)
      end
    end

    context "without authenticated user" do
      it "renders a JSON response with a user" do
        get :show
        expect(response).to have_http_status(:unauthorized)
        expect(response.content_type).to match %r(application/json)
        body = JSON.parse(response.body)
        expect(body["error_message"]).to be_present
      end
    end

  end

  describe "POST #create" do
    context "with valid params" do
      let(:user) { create :user, password: "youdontknow" }
      let(:valid_attributes) {
        {
          email: user.email,
          password: "youdontknow"
        }
      }

      it "renders a JSON response with a new token" do
        post :create, params: valid_attributes
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match %r(application/json)
        body = JSON.parse(response.body)
        expect(body["token"]).to be_present
      end
    end

    context "with non-existing user" do
      let(:invalid_attributes) {
        {
          email: "no-such-user@raphroaig.test",
          password: "something"
        }
      }

      it "renders a JSON response with errors" do
        post :create, params: invalid_attributes
        expect(response).to have_http_status(:not_found)
        expect(response.content_type).to match %r(application/json)
        body = JSON.parse(response.body)
        expect(body["error_message"]).to be_present
      end
    end

    context "with wrong password" do
      let(:user) { create :user, password: "youdontknow" }
      let(:invalid_attributes) {
        {
          email: user.email,
          password: "maybethis"
        }
      }

      it "renders a JSON response with errors" do
        post :create, params: invalid_attributes
        expect(response).to have_http_status(:not_found)
        expect(response.content_type).to match %r(application/json)
        body = JSON.parse(response.body)
        expect(body["error_message"]).to be_present
      end
    end
  end
end
