class Api::PicturesController < ApiController
  before_action :set_picture_attachment, only: [:destroy]

  def index
    @pictures = Picture.includes(user_attachment: :user).order(id: :desc)
    render json: @pictures.each_with_object(Picture).map(&:becomes).map(&method(:index_attributes))
  end

  def create
    current_user.pictures.attach params.require(:file)
    render :no_content, status: :created
  end

  def destroy
    @picture_attachment.destroy
  end

  private

  def set_picture_attachment
    @picture_attachment = UserPicturesAttachment.find(params[:id])
  end

  def index_attributes picture
    a = picture.user_attachment
    a.attributes
      .slice(*%w(id created_at))
      .merge(picture.slice(*%w(filename byte_size)))
      .merge(
        user: a.user.attributes,
        url: rails_blob_url(picture),
        thumbnail_url: rails_representation_url(picture.variant(resize_to_fill: [300, 300]).processed)
      )
  end

end
