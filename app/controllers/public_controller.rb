class PublicController < ApplicationController
  def index
    @games =
      Game
        .not_finished
        .order(updated_at: :desc)
        .limit(18)
    @pictures =
      Picture
        .order(created_at: :desc)
        .where(
          id: UserPicturesAttachment.select(:blob_id)
        )
  end
end
