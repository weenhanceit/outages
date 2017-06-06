class CreateOutages < ActiveRecord::Migration[5.1]
  def change
    create_table :outages do |t|
      t.belongs_to :account, foreign_key: true, index: true
      t.boolean :active, null: false
      t.boolean :causes_loss_of_service, null: false
      t.boolean :completed, null: false
      t.text :description
      t.datetime :end_time, index: true
      t.string :name
      t.datetime :start_time, index: true
      t.timestamps
    end
  end
end
