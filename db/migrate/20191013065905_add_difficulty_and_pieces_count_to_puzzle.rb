class AddDifficultyAndPiecesCountToPuzzle < ActiveRecord::Migration[6.0]
  def change
    add_column :puzzles, :difficulty, :string
    add_column :puzzles, :pieces_count, :integer
  end
end
