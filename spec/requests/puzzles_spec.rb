require 'rails_helper'

RSpec.describe "Puzzles", type: :request do
  describe "GET /puzzles" do
    it "works! (now write some real specs)" do
      get puzzles_path
      expect(response).to have_http_status(200)
    end
  end
end
