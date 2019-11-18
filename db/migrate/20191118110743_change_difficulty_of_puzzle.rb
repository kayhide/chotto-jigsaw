class ChangeDifficultyOfPuzzle < ActiveRecord::Migration[6.0]
  def change
    change_column_null :puzzles, :difficulty, false
  end
end
