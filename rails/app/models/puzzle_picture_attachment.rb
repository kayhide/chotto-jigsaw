class PuzzlePictureAttachment < ActiveStorage::Attachment
  default_scope { where(record_type: "Puzzle", name: "picture") }

  belongs_to :puzzle, foreign_key: :record_id
  belongs_to :picture, foreign_key: :blob_id
end
