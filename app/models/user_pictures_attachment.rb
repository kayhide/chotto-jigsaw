class UserPicturesAttachment < ActiveStorage::Attachment
  default_scope { where(record_type: "User", name: "pictures") }

  belongs_to :user, foreign_key: :record_id
  belongs_to :picture, foreign_key: :blob_id
end
