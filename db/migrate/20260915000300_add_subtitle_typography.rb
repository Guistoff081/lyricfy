class AddSubtitleTypography < ActiveRecord::Migration[8.1]
  def change
    [:projects, :exports].each do |table|
      add_column table, :subtitle_font, :string, null: false, default: "Liberation Serif"
      add_column table, :subtitle_size, :integer, null: false, default: 24
    end
  end
end
