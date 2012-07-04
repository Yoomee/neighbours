class Post < ActiveRecord::Base
  
  include YmPosts::Post

  has_many :notifications, :as => :resource
  
  after_create :create_notification
  
  private
  def create_notification
    if target_type == "Need"
      # Notify user they have a new offer
      notifications.create(:user => target.user, :context => "my_requests")
    end
  end
  
end