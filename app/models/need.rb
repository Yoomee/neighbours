class Need < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :category, :class_name => "NeedCategory"
  has_many :offers, :dependent => :destroy
  has_many :posts, :as => :target, :dependent => :destroy
  has_one :accepted_offer, :class_name => 'Offer', :conditions => {:accepted => true}
  
  validates :user, :presence => {:unless => :skip_user_validation?}
  validates :category, :presence => true
  validates :description, :presence => true
  # validate :deadline_is_in_future

  scope :unresolved, where("NOT EXISTS (SELECT * FROM offers WHERE offers.need_id = needs.id AND offers.accepted = true)")
  scope :resolved, where("EXISTS (SELECT * FROM offers WHERE offers.need_id = needs.id AND offers.accepted = true)")
  
  boolean_accessor :skip_user_validation
  
  define_index do
    indexes description
    has user_id, category_id, deadline, created_at, updated_at
  end
  
  def notifications
    Notification.where(["(resource_type = 'Comment' AND resource_id IN (:comment_ids)) OR (resource_type = 'Post' AND resource_id IN (:post_ids))", {:comment_ids => Comment.where(["post_id IN (?)", post_ids]), :post_ids => post_ids}])
  end
  
  def read_all_notifications!(user)
    context = (self.user == user) ? 'my_requests' : 'my_offers'
    notifications.where(["context = '#{context}' AND notifications.user_id = ?", user.id]).update_all(:read => true)
  end
  
  def valid_without_user?
    self.skip_user_validation = true
    is_valid = valid?
    self.skip_user_validation = false
    is_valid
  end
  
  def title
    category.to_s
  end
  
  private  
  # def deadline_is_in_future
  #   if new_record? && deadline.present? && (deadline < Date.today)
  #     errors.add(:deadline, "must be in the future")
  #   end
  # end
  
end