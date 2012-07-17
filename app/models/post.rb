class Post < ActiveRecord::Base
  
  include YmPosts::Post

  has_many :notifications, :as => :resource
  
  after_create :create_notification
  
  scope :visible_to, lambda {|user| where(["posts.private = 0 OR posts.user_id = :user_id OR (posts.target_type = 'User' AND posts.target_id = :user_id)", {:user_id => user.id}]) }
  
  private
  def create_notification
    if target_type == "Need"
      # Notify user they have a new offer
      notifications.create(:user => target.user, :context => "my_requests")
    end
  end
  
end