class AddProgressToGames < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :progress, :float, default: 0.0
  end
end
