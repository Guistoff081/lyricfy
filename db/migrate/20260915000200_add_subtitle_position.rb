class AddSubtitlePosition < ActiveRecord::Migration[8.1]
  def change
    add_column :projects, :subtitle_position, :string, null: false, default: "center"
    add_column :exports, :subtitle_position, :string, null: false, default: "center"
  end
end
