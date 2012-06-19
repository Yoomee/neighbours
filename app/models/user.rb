class User < ActiveRecord::Base
  
  include YmUsers::User
  include YmCore::Multistep  
  
  def steps
    %w{who_you_are where_you_live validate}
  end
  
end