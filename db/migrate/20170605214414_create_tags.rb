class CreateTags < ActiveRecord::Migration[5.1]
  def change
    create_table :tags do |t|
      t.belongs_to :account, index: true
      t.belongs_to :taggable, polymorphic: true, index: true
      t.text :name
      t.timestamps
    end
  end
end
