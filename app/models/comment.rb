class Comment < ActiveRecord::Base
  
  include YmPosts::Comment
  
  has_many :notifications, :as => :resource
  
  after_create :create_notification
  
  def read_by?(user)
    !notifications.exists?(:user_id => user.id, :read => false)
  end
  
  private
  def create_notification
    if user == post.user && post.target_type == "Need"
      # Notify user their request has been commented on
      notifications.create(:user => post.target.user, :context => "my_requests")
    else
      # Notify user their offer has been commented on
      notifications.create(:user => post.user, :context => "my_offers")
    end
  end
  
end