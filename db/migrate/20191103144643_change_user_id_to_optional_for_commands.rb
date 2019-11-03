class ChangeUserIdToOptionalForCommands < ActiveRecord::Migration[6.0]
  def change
    change_column :commands, :user_id, :bigint, null: true
  end
end
