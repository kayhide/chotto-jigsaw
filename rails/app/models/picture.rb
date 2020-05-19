class Picture < ActiveStorage::Blob
  has_one :user_pictures_attachment, foreign_key: :blob_id
  has_one :user, through: :user_pictures_attachment
  has_many :puzzle_picture_attachments, foreign_key: :blob_id
  has_many :puzzles, through: :puzzle_picture_attachments

end
