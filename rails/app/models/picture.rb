class Picture < ActiveStorage::Blob
  has_one :user_attachment, foreign_key: :blob_id, class_name: :UserPicturesAttachment
  has_one :user, through: :user_attachment

  has_many :puzzle_attachments, foreign_key: :blob_id, class_name: :PuzzlePictureAttachment
  has_many :puzzles, through: :puzzle_attachments

  def blob
    becomes(self.class.superclass)
  end
end
