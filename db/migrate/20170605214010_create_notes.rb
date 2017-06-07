class CreateNotes < ActiveRecord::Migration[5.1]
  def change
    create_table :notes do |t|
      t.belongs_to :notable, polymorphic: true, index: true
      t.belongs_to :user, foreign_key: true, index: true

      t.text :note
      t.timestamps
    end
  end
end
