class CreateSamples < ActiveRecord::Migration
  def self.up
    create_table :samples do |t|
      t.string :name
      t.string :cd
      t.string :kana
      t.string :url
      t.string :zip
      t.string :prefecture
      t.string :address
      t.string :building
      t.references :visible
      t.text :memo

      t.integer  :lock_version, :null => false, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :samples
  end
end
