class Sample < ActiveRecord::Base
  attr_accessible :name, :kana
  belongs_to :visible
  validates_presence_of :name
end
