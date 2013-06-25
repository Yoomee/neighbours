class GeneralOffer < ActiveRecord::Base

  include HasShoutRadius
  include Autopostable

  belongs_to :user
  belongs_to :category, :class_name => "NeedCategory"
  belongs_to :sub_category, :class_name => "NeedCategory"
  has_many :offers
  has_many :flags, :as => :resource, :dependent => :destroy

  validates :category, :description, :presence => true

  delegate :lat, :lng, :street_name, :to => :user
  delegate :first_name, :to => :user, :prefix => true

  define_index do
    indexes description
    has id, user_id, category_id, radius, created_at, updated_at
    join user
    has "RADIANS(users.lat)",  :as => :latitude,  :type => :float
    has "RADIANS(users.lng)", :as => :longitude, :type => :float
    set_property :delta => true
  end

  class << self
    
    def visible_to_user_with_validated_users(user)
      if user.try(:admin?)
        visible_to_user_without_validated_users(user)
      else
        visible_to_user_without_validated_users(user).joins(:user).select('general_offers.*, users.validated').where(:users => {:validated => true})
      end
    end
    alias_method_chain :visible_to_user, :validated_users
    
  end
  
  def autopost_url
    "#{Settings.site_url}/general_offers/#{id}"
  end
  
  def autopost_text
    if user.neighbourhood
      "#{user} from #{user.neighbourhood} has offered to help with #{title}"
    else
      "#{user} has offered to help with #{title}"
    end
  end

  def create_need_for_user(user_wanting_help)
    if user_wanting_help == self.user
      "You can't accept your own offer"
    else
      need = Need.create(:user => user_wanting_help, :category => self.category, :skip_description_validation => true)
      offer = offers.create(:need => need, :user => self.user, :post_for_need => self.description, :accepted => true)
      offer.need.posts.first.comments.create(:user => user_wanting_help, :text => "I would like to accept your offer for help")
      need
    end
  end
  
  def title
    [category,sub_category].compact.map(&:to_s).join(': ')
  end

end