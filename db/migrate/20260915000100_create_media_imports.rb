class CreateMediaImports < ActiveRecord::Migration[8.1]
  def change
    create_table :media_imports do |t|
      t.string :url, null: false
      t.string :status, null: false, default: "queued"
      t.text :error_message
      t.text :warning
      t.references :project, foreign_key: true
      t.timestamps
    end
    add_index :media_imports, :status
  end
end
