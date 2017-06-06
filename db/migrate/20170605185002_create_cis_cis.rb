class CreateCisCis < ActiveRecord::Migration[5.1]
  def change
    create_table :cis_cis do |t|
      t.belongs_to :parent, foreign_key: { to_table: :cis }, index: true
      t.belongs_to :child, foreign_key: { to_table: :cis }, index: true
      t.timestamps
    end
  end
end
