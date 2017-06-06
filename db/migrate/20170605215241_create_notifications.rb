class CreateNotifications < ActiveRecord::Migration[5.1]
  def change
    create_table :notifications do |t|
      t.belongs_to :event, foreign_key: true, index: true
      t.belongs_to :watch, foreign_key: true, index: true
      t.integer :notification_type, default: 0
      t.boolean :notified, null: false
      t.timestamps
    end
  end
end
