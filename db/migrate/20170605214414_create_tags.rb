class CreateTags < ActiveRecord::Migration[5.1]
  def change
    create_table :tags do |t|
      t.belongs_to :tagable, polymorphic: true, index: true
      t.text :notes
      t.timestamps
    end
  end
end
