class AddBoundaryToPuzzle < ActiveRecord::Migration[6.0]
  def change
    add_column :puzzles, :boundary_x, :float
    add_column :puzzles, :boundary_y, :float
    add_column :puzzles, :boundary_width, :float
    add_column :puzzles, :boundary_height, :float
  end
end
