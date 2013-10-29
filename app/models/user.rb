class User < ActiveRecord::Base
  attr_accessible :account, :password, :name

  require 'digest/sha1'

  validates_presence_of     :name
  validates_length_of       :name,     :maximum => 50
  validates_presence_of     :account
  validates_length_of       :account,  :maximum => 50
  validates_uniqueness_of   :account
  validates_presence_of     :password
  validates_length_of       :password, :maximum => 50
  validates_confirmation_of :password

  attr_accessor :password_confirmation
  attr_accessor :password_required

  def password
    @password
  end

  def password=(pwd)
    @password = pwd
    return if pwd.blank?
    create_new_salt
    self.hashed_password = User.encrypted_password(self.password, self.salt)
  end

  def self.authenticate(id, password)
    user = self.find_by_account(id)
    if user
      if (user.hashed_password.blank? || user.salt.blank?) && (password.blank? || id == password)
        user.password = id
        user.update_attribute(:hashed_password, user.hashed_password)
        user.update_attribute(:salt, user.salt)
      else
        expected_password = encrypted_password(password, user.salt)
        if user.hashed_password != expected_password
          user = nil
        end
      end
    end
    user
  end

private
  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end

  def self.encrypted_password(password, salt)
    string_to_hash = password + "1qazxsw2" + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end
end
