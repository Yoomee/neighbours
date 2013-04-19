class GeneralOffer < ActiveRecord::Base

  belongs_to :user
  belongs_to :category, :class_name => "NeedCategory"
  belongs_to :sub_category, :class_name => "NeedCategory"
  has_many :offers

  validates :category, :description, :presence => true

  class << self
    
    def visible_to_user(user)
      if user.try(:admin?)
        where("1 = 1")
      elsif user.try(:neighbourhood_id).present?
        joins(:user).where(:users => {:neighbourhood_id => user.neighbourhood_id, :validated => true})
      else
        where("1 = 0")
      end
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