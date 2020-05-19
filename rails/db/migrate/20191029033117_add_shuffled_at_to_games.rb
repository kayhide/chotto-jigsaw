class AddShuffledAtToGames < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :shuffled_at, :datetime
  end
end
