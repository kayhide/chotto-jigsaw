require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  authenticate_user

  let(:valid_attributes) {
    {
      username: "User 1",
      email: "user-1@chotto-zigsaw.test"
    }
  }

  let(:invalid_attributes) {
    {
      username: nil
    }
  }

  describe "GET #index" do
    it "returns a success response" do
      User.create! valid_attributes
      get :index, params: {}
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      user = User.create! valid_attributes
      get :show, params: { id: user.id }
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
      user = User.create! valid_attributes
      get :edit, params: { id: user.id }
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new User" do
        expect {
          post :create, params: {user: valid_attributes}
        }.to change(User, :count).by(1)
      end

      it "redirects to the created user" do
        post :create, params: { user: valid_attributes }
        expect(response).to redirect_to(User.last)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { user: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        {
          username: "Taro"
        }
      }

      it "updates the requested user" do
        user = User.create! valid_attributes
        expect {
          put :update, params: { id: user.id, user: new_attributes }
        }.to change { user.reload.username }.to("Taro")
      end

      it "redirects to the user" do
        user = User.create! valid_attributes
        put :update, params: { id: user.id, user: valid_attributes }
        expect(response).to redirect_to(user)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'edit' template)" do
        user = User.create! valid_attributes
        put :update, params: { id: user.id, user: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested user" do
      user = User.create! valid_attributes
      expect {
        delete :destroy, params: {id: user.id}
      }.to change(User, :count).by(-1)
    end

    it "redirects to the users list" do
      user = User.create! valid_attributes
      delete :destroy, params: { id: user.id }
      expect(response).to redirect_to(users_url)
    end
  end

end
