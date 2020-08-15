module FirebaseToken
  extend ActiveSupport::Concern

  attr_reader :firebase_token

  def set_firebase_token game
    uid = current_user_id ? "user-#{current_user_id}" : "guest"
    @firebase_token = FireRecord::Client.create_custom_token uid, game_id: game.id.to_s
  end

  def add_firebase_token_response_header game
    response.headers["Firebase-Token"] = set_firebase_token game
  end
end
