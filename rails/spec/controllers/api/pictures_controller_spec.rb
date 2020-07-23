require 'rails_helper'

RSpec.describe Api::PicturesController, type: :controller do
  authenticate_user

  let(:file) { 'pictures/mountain.jpg' }
  let(:file_path) { fixture_path.join file }
  let(:file_param) { fixture_file_upload file }
  let(:valid_params) {
    {
      file: file_param
    }
  }

  describe "GET #index" do
    let!(:picture_attachments) {
      2.times.map do
        current_user.pictures.attach(io: File.open(file_path), filename: File.basename(file))
      end
      current_user.pictures.order(id: :asc).map { |a| a.becomes UserPicturesAttachment }
    }

    it "returns picture items" do
      get :index
      expect(response).to have_http_status(:ok)
      body = JSON.parse response.body
      expect(body.count).to eq 2
      expect(body.map(&:keys)).to all match_array %w(id created_at filename byte_size user url thumbnail_url)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      let(:valid_params) {
        {
          file: fixture_file_upload(file)
        }
      }

      it "returns created status" do
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
        expect(response.body).to be_blank
      end

      it "creates a Picture" do
        expect {
          post :create, params: valid_params
        }.to change(Picture, :count).by(1)
      end
    end

    context "with multiple files" do
      let(:valid_params) {
        {
          file: [ fixture_file_upload(file), fixture_file_upload(file) ]
        }
      }

      it "creates multiple Pictures" do
        expect {
          post :create, params: valid_params
        }.to change(Picture, :count).by(2)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:picture_attachment) {
      current_user.pictures.attach(io: File.open(file_path), filename: File.basename(file))
      current_user.pictures_attachments.last.becomes(UserPicturesAttachment)
    }

    it "destroys the picture association" do
      expect {
        delete :destroy, params: { id: picture_attachment.id }
      }.to change { current_user.pictures.count }.by(-1)
    end

    it "enqueues PurgeJob" do
      assert_enqueued_with job: ActiveStorage::PurgeJob do
        delete :destroy, params: { id: picture_attachment.id }
      end
    end
  end

end
