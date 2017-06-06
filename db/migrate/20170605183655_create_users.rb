class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.belongs_to :account, foreign_key: true, index: true
      t.string :email, null: false
      t.string :name
      t.integer :notification_periods_before_outage
      t.string :notification_period_interval
      t.boolean :active, null: false
      t.boolean :notify_me_before_outage, null: false
      t.boolean :notify_me_on_outage_changes, null: false
      t.boolean :notify_me_on_note_changes, null: false
      t.boolean :notify_me_on_outage_complete, null: false
      t.boolean :notify_me_on_overdue_outage, null: false
      t.time :preference_email_time
      t.boolean :preference_individual_email_notifications, null: false
      t.boolean :preference_notifiy_me_by_email, null: false
      t.boolean :privilege_account, null: false
      t.boolean :privilede_edit_cis, null: false
      t.boolean :privilege_edit_outages, null: false
      t.boolean :privilege_manage_users, null: false
      t.string :time_zone

      t.timestamps
    end
  end
end
