class Log < ActiveRecord::Base
  attr_accessible :user_id, :action, :error
  belongs_to :user
end
