class AttachPicturesToUsers < ActiveRecord::Migration[6.0]
  def change
    reversible do |dir|
      dir.up do
        User.find_each do |user|
          user.puzzles.find_each do |puzzle|
            user.pictures.attach puzzle.picture_blob
          end
        end
      end
    end
  end
end
