class CreateCisOutages < ActiveRecord::Migration[5.1]
  def change
    create_table :cis_outages do |t|
      t.belongs_to :ci, foreign_key: true, index: true
      t.belongs_to :outage, foreign_key: true, index: true

      t.timestamps
    end
  end
end
