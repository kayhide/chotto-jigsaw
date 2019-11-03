class Command < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :game

  validates :piece_id, presence: true

  def command_attributes
    attributes.slice(*%w(type created_at piece_id))
  end
end
