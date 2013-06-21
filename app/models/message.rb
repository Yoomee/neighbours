class Message < ActiveRecord::Base

  include YmMessages::Message

  class << self
    
    def valid_recipients_for_user(user)
      return [] if user.no_private_messaging?
      User.without(user).joins(:groups).where('no_private_messaging = 0 AND groups.id IN (?)', user.group_ids).group('users.id')
    end
    
  end

end