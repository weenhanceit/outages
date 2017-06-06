class CreateWatches < ActiveRecord::Migration[5.1]
  def change
    create_table :watches do |t|
      t.belongs_to :user, foreign_key: true, index: true
      t.belongs_to :watched, polymorphic: true, index: true
      t.timestamps
    end
  end
end
