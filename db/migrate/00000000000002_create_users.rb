class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string   :account
      t.string   :name
      t.string   :hashed_password
      t.string   :salt
      t.integer  :role

      t.integer  :lock_version, :null => false, :default => 0
      t.timestamps
    end
    add_index :users, :account, :unique => true
  end

  def self.down
    drop_table :users
  end
end
