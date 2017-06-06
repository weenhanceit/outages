class CreateCis < ActiveRecord::Migration[5.1]
  def change
    create_table :cis do |t|
      t.belongs_to :account, foreign_key: true, index: true
      t.boolean :active, null: false
      t.text :description
      t.string :name
      t.integer maximum_unavailable_children_with_service_maintained
      t.integer minimum_children_to_maintain_service
      t.timestamps
    end
  end
end
