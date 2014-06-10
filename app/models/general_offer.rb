class GeneralOffer < ActiveRecord::Base

  include HasShoutRadius
  include Autopostable

  belongs_to :user
  belongs_to :category, :class_name => "NeedCategory"
  belongs_to :sub_category, :class_name => "NeedCategory"
  has_many :offers
  has_many :needs, :through => :offers
  has_many :flags, :as => :resource, :dependent => :destroy
  has_many :posts, :as => :target, :dependent => :destroy

  validates :category, :description, :presence => true

  before_create :prepare_for_autopost
  after_create :autopost

  default_scope where(:removed_at => nil)

  attr_accessor :current_user # used for miles_from_s on home#index

  delegate :lat, :lng, :street_name, :to => :user
  delegate :first_name, :to => :user, :prefix => true

  define_index do
    indexes description
    has id, user_id, category_id, radius, created_at, updated_at
    join user
    has "RADIANS(users.lat)",  :as => :latitude,  :type => :float
    has "RADIANS(users.lng)", :as => :longitude, :type => :float
    where "removed_at IS NULL"
    set_property :delta => true
  end

  self.per_page = 5

  class << self
    
    def visible_to_user_with_validated_users(user)
      if user.try(:admin?) || user.try(:is_organisation_admin?)
        visible_to_user_without_validated_users(user)
      else
        visible_to_user_without_validated_users(user).joins(:user).select('general_offers.*, users.validated').where(:users => {:validated => true})
      end
    end
    alias_method_chain :visible_to_user, :validated_users
    
  end
  
  # hack to pass current_user to to_json on home#index
  def as_json(options = {})
    self.current_user = options[:current_user]
    super
  end

  def autopost_text
    out = user.neighbourhood ? "#{user} from #{user.neighbourhood}" : user.to_s
    "#{out} has offered to help with #{title}"
  end

  def create_need_for_user(user_wanting_help)
    if user_wanting_help == self.user
      "You can't accept your own offer"
    else
      need = Need.create(:user => user_wanting_help, :category => self.category, :skip_description_validation => true)
      offer = unscoped_offers.create(:need => need, :user => self.user, :post_for_need => self.description, :accepted => true)
      offer.need.posts.first.comments.create(:user => user_wanting_help, :text => Settings.offer_acceptance_text)
      need
    end
  end
  
  def miles_from_s(user = self.current_user)
    return '' if user.nil?
    self.user.miles_from_s(user)
  end

  def notifications
    Notification.where(["(resource_type = 'Comment' AND resource_id IN (:comment_ids)) OR (resource_type = 'Post' AND resource_id IN (:post_ids))", {:comment_ids => Comment.where(["post_id IN (?)", post_ids]), :post_ids => post_ids}])
  end

  def posts_viewable_by(user)
    (user == self.user || user.try(:admin?)) ? posts.where("posts.removed_at IS NULL") : posts.where(["posts.user_id = ?", user.try(:id)]).where("posts.removed_at IS NULL")
  end

  def read_all_notifications!(user)
    context = (self.user == user) ? 'my_offers' : 'my_requests'
    notifications.where(["context = '#{context}' OR context = '#{context}_chat' AND notifications.user_id = ?", user.id]).update_all(:read => true)
  end

  def removed?
    removed_at.present?
  end

  def title
    [category,sub_category].compact.map(&:to_s).join(': ')
  end

  def unscoped_offers
    Offer.unscoped.where(:general_offer_id => id)
  end

end