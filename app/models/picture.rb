class Picture < ActiveStorage::Blob
  has_many :picture_attachments, foreign_key: :blob_id
  has_many :puzzles, through: :picture_attachments

end
