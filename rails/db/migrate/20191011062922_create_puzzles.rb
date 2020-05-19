class CreatePuzzles < ActiveRecord::Migration[6.0]
  def change
    create_table :puzzles do |t|
      t.references :user
      t.float :linear_measure

      t.timestamps
    end
  end
end
