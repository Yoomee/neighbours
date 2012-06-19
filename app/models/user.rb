class User < ActiveRecord::Base
  include YmUsers::User
  
  has_many :needs
  
end