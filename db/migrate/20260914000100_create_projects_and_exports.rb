class CreateProjectsAndExports < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.string :title, null: false
      t.string :original_filename, null: false
      t.string :media_kind, null: false
      t.float :duration, null: false
      t.text :subtitle_text, null: false, default: ""
      t.timestamps
    end
    create_table :exports do |t|
      t.references :project, null: false, foreign_key: true
      t.string :status, null: false, default: "queued"
      t.string :aspect, null: false, default: "original"
      t.float :start_seconds, null: false, default: 0
      t.float :end_seconds, null: false
      t.text :subtitle_text, null: false
      t.text :error_message
      t.timestamps
    end
  end
end
