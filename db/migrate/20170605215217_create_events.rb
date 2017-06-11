class CreateEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :events do |t|
      t.boolean :handled, null: false
      t.belongs_to :outage, foreign_key: true, index: true
      t.text :text
      t.integer :event_type, default: 0
      t.timestamps
    end
  end
end
