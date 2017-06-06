class CreateContributors < ActiveRecord::Migration[5.1]
  def change
    create_table :contributors do |t|
      t.belongs_to :outage, foreign_key: true, index: true
      t.belongs_to :user, foreign_key: true, index: true

      t.timestamps

    end
  end
end
