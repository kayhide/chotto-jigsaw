class CreateCommands < ActiveRecord::Migration[6.0]
  def change
    create_table :commands do |t|
      t.references :user, null: false, foreign_key: true
      t.references :game, null: false, foreign_key: true
      t.string :type
      t.integer :piece_id
      t.timestamps

      t.integer :merge_mergee_id

      t.float :transform_position_x
      t.float :transform_position_y
      t.float :transform_rotation

      t.float :translate_delta_x
      t.float :translate_delta_y

      t.float :rotate_pivot_x
      t.float :rotate_pivot_y
      t.float :rotate_delta_degree
    end
  end
end
