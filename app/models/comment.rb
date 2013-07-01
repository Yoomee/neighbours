class Comment < ActiveRecord::Base
  
  include YmPosts::Comment
  
  has_many :notifications, :as => :resource, :dependent => :destroy
  
  after_create :create_notification
  
  def read_by?(user)
    !notifications.exists?(:user_id => user.id, :read => false)
  end

  def email_users
    users_to_email.each do |user|
      UserMailer.new_comment(self, user).deliver
    end
  end

  private
  def create_notification
    if user == post.user && post.target_type == "Need"
      # Notify user their request has been commented on
      notifications.create(:user => post.target.user, :context => "my_requests")
    elsif post.target_type == 'Need'
      # Notify user their offer has been commented on
      notifications.create(:user => post.user, :context => "my_offers")
    end
  end
  
  def users_to_email
    ([post.user] + post.users_that_commented - [user]).uniq
  end

end