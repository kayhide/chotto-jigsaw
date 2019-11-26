class PublicController < ApplicationController
  def index
    @games =
      Game
        .active
        .order(updated_at: :desc)
        .limit(18)
    @pictures =
      Picture
        .order(created_at: :desc)
        .where(
          id: PictureAttachment.distinct.select(:blob_id)
        )
  end
end
