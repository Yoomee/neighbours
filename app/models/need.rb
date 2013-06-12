class Need < ActiveRecord::Base

  include HasShoutRadius
  include Autopostable

  belongs_to :user
  belongs_to :category, :class_name => "NeedCategory"
  belongs_to :sub_category, :class_name => "NeedCategory"
  has_many :offers, :dependent => :destroy
  has_many :posts, :as => :target, :dependent => :destroy
  has_many :flags, :as => :resource, :dependent => :destroy
  has_one :accepted_offer, :class_name => 'Offer', :conditions => {:accepted => true}

  validates :user, :presence => {:unless => :skip_user_validation?}
  validates :category, :presence => true
  validates :description, :presence => {:unless => :skip_description_validation?}
  validate :deadline_is_in_future
  
  default_scope where(:removed => false)

  scope :unresolved, joins(:user).where("NOT EXISTS (SELECT * FROM offers WHERE offers.need_id = needs.id AND offers.accepted = true)")
  scope :resolved, joins(:user).where("EXISTS (SELECT * FROM offers WHERE offers.need_id = needs.id AND offers.accepted = true)")
  scope :with_lat_lng, joins(:user).where("users.lat IS NOT NULL AND users.lng IS NOT NULL")

  boolean_accessor :skip_user_validation, :skip_description_validation

  delegate :lat, :lng, :street_name, :to => :user
  delegate :first_name, :to => :user, :prefix => true

  define_index do
    indexes description
    has id, user_id, category_id, deadline, radius, created_at, updated_at
    join user
    has "RADIANS(users.lat)",  :as => :latitude,  :type => :float
    has "RADIANS(users.lng)", :as => :longitude, :type => :float
    set_property :delta => true
  end

  def description
    return read_attribute(:description) if new_record?
    read_attribute(:description).presence || category.description
  end
  
  def has_accepted_offer?
    accepted_offer.present?
  end

  def notifications
    Notification.where(["(resource_type = 'Comment' AND resource_id IN (:comment_ids)) OR (resource_type = 'Post' AND resource_id IN (:post_ids))", {:comment_ids => Comment.where(["post_id IN (?)", post_ids]), :post_ids => post_ids}])
  end

  def posts_viewable_by(user)
    (user == self.user || user.try(:admin?)) ? posts : posts.where(["posts.user_id = ?", user.try(:id)])
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
    [category,sub_category].compact.map(&:to_s).join(': ')
  end
  
  def autopost_url
    "#{Settings.site_url}/needs/#{id}"
  end
  
  def autopost_text
    if user.neighbourhood
      "#{user} from #{user.neighbourhood} needs help with #{title}"
    else
      "#{user} needs help with #{title}"
    end
  end

  private
  def deadline_is_in_future
    if new_record? && deadline.present? && (deadline < Date.today)
      errors.add(:deadline, "must be in the future")
    end
  end

end

Need::RADIUS_OPTIONS = [
  ["1/4 mile", 0.25],
  ["1/2 mile", 0.5],
  ["1 mile",   1],
  ["2 miles",  2],
  ["5 miles",  5],
  ["10 miles", 10]
]