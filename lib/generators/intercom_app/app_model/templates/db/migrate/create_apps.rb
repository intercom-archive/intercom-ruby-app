class CreateApps < ActiveRecord::Migration
  def self.up
    create_table :apps  do |t|
      t.string :intercom_app_id, null: false
      t.string :intercom_token, null: false
      t.timestamps
    end

    add_index :apps, :intercom_app_id, unique: true
  end

  def self.down
    drop_table :apps
  end
end
