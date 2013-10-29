class CreateLogs < ActiveRecord::Migration
  def self.up
    create_table :logs do |t|
      t.integer :user_id, :null => false
      t.string  :action
      t.string  :error

      t.timestamps
    end
  end

  def self.down
    drop_table :logs
  end
end
