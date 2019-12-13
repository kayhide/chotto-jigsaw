class Command
  include FireRecord::Document

  has_one :user
  belongs_to :game
  attribute :piece_id, :integer
  attribute :created_at, :datetime

  validates :piece_id, presence: true

  def command_attributes
    attributes.slice(*%w(type created_at piece_id))
  end
end
