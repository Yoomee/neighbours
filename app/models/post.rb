class Post < ActiveRecord::Base
  
  include YmPosts::Post

  has_many :users_that_commented, :through => :comments, :source => :user
  has_many :notifications, :as => :resource, :dependent => :destroy 
  has_many :flags, :as => :resource, :dependent => :destroy  
  
  after_create :create_notification
  
  scope :visible_to, lambda {|user| where(["posts.private = 0 OR posts.user_id = :user_id OR (posts.target_type = 'User' AND posts.target_id = :user_id)", {:user_id => user.id}]) }
  
  self.per_page = 10
  
  class << self
    
    def page_number_for(post_or_id, options = {})
      options.reverse_merge!(:per_page => Post.per_page)
      post_id = post_or_id.is_a?(Post) ? post_or_id.id : post_or_id
      index = select('posts.id').collect(&:id).index(post_or_id.to_i)
      (index / options[:per_page]) + 1
    end
    
  end
  
  private
  def create_notification
    if target_type == "Need"
      # Notify user they have a new offer or a chat
      if context == 'chat'
        notifications.create(:user => target.user, :context => "my_requests_chat")
      else
        notifications.create(:user => target.user, :context => "my_requests")
      end
    elsif target_type == "GeneralOffer"
      #Someone is chatting on their offer
      notifications.create(:user => target.user, :context => "my_offers_chat")
    end
  end

end