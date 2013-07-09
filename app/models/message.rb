class Message < ActiveRecord::Base

  include YmMessages::Message

  class << self
    
    def valid_recipients_for_user(user)
      users = User.without(user).not_deleted
      return users if user.admin?
      return [] if user.no_private_messaging?
      users.joins(:groups).where('no_private_messaging = 0 AND groups.id IN (?)', user.group_ids).group('users.id')
    end
    
  end

end