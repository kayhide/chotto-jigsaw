class Command
  include FireRecord::Document

  has_one :user
  belongs_to :game
  attribute :type, :string
  attribute :piece_id, :integer
  attribute :created_at, :datetime

  validates :piece_id, presence: true
end
