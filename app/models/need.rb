class Need < ActiveRecord::Base

  belongs_to :user
  belongs_to :category, :class_name => "NeedCategory"
  belongs_to :sub_category, :class_name => "NeedCategory"
  has_many :offers, :dependent => :destroy
  has_many :posts, :as => :target, :dependent => :destroy
  has_many :flags, :as => :resource, :dependent => :destroy
  has_one :accepted_offer, :class_name => 'Offer', :conditions => {:accepted => true}

  validates :user, :presence => {:unless => :skip_user_validation?}
  validates :category, :presence => true
  validates :description, :presence => true
  validate :sub_category_if_available
  validate :deadline_is_in_future

  scope :unresolved, joins(:user).where("NOT EXISTS (SELECT * FROM offers WHERE offers.need_id = needs.id AND offers.accepted = true)")
  scope :resolved, joins(:user).where("EXISTS (SELECT * FROM offers WHERE offers.need_id = needs.id AND offers.accepted = true)")
  scope :with_lat_lng, joins(:user).where("users.lat IS NOT NULL AND users.lng IS NOT NULL")

  boolean_accessor :skip_user_validation

  delegate :lat, :lng, :street_name, :to => :user
  delegate :first_name, :to => :user, :prefix => true

  define_index do
    indexes description
    has user_id, category_id, deadline, radius, created_at, updated_at
    join user
    has "RADIANS(users.lat)",  :as => :latitude,  :type => :float
    has "RADIANS(users.lng)", :as => :longitude, :type => :float
    set_property :delta => true
  end
  
  class << self
    
    def default_radius
      radius_options[2].last
    end
    
    def maximum_radius
      radius_options.last.last
    end
        
    def radius_options
      Need::RADIUS_OPTIONS.map do |name, miles|
        [name, (miles * 1609.344).round]
      end
    end
  
    def visible_from_location(lat,lng)
      sphinx_search = search_for_ids({
        :with => { "@geodist" => 0.0..Need.maximum_radius.to_f },
        :geo => [(lat.to_f*Math::PI/180),(lng.to_f*Math::PI/180)],
        :per_page => 100000
      })
      need_ids = []
      sphinx_search.results[:matches].each do |match|
        if match[:attributes]["radius"].to_f > match[:attributes]["@geodist"].to_f
          need_ids << match[:doc] 
        end
      end
      where("needs.id IN (?)", need_ids)
    end
    
    def visible_to_user(user)
      if user.admin?
        where("1 = 1")
      elsif user.has_lat_lng?
        visible_from_location(user.lat,user.lng)
      else
        where("1 = 0")
      end
    end
    
  end

  def has_accepted_offer?
    accepted_offer.present?
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
    [category,sub_category].compact.map(&:to_s).join(': ')
  end

  private
  def deadline_is_in_future
    if new_record? && deadline.present? && (deadline < Date.today)
      errors.add(:deadline, "must be in the future")
    end
  end
  
  def sub_category_if_available
    if category && !sub_category && !category.sub_categories.count.zero?
      self.errors.add(:sub_category, "can't be blank")
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