class Api::PicturesController < ApiController
  before_action :set_picture_attachment, only: [:destroy]

  def index
    @pictures = UserPicturesAttachment.includes(:user, :picture).order(id: :desc)
    render json: @pictures.map(&method(:index_attributes))
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

  def index_attributes a
    a.attributes
      .slice(*%w(id created_at))
      .merge(a.picture.slice(*%w(filename byte_size)))
      .merge(
        user: a.user.attributes,
        url: rails_blob_url(a.picture),
        thumbnail_url: rails_representation_url(a.picture.variant(resize_to_fill: [300, 300]).processed)
      )
  end

end
