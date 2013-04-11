class Offer < ActiveRecord::Base
  
  belongs_to :need
  belongs_to :user
  belongs_to :category, :class_name => "NeedCategory"
  belongs_to :sub_category, :class_name => "NeedCategory"
  
  after_create :create_post_for_need
  
  attr_accessor :post_for_need
  
  validates :user, :presence => true
  validates :category, :description, :presence => {:if => :general_offer?}
  validates :post_for_need, :presence => {:on => :create, :unless => :general_offer?}
  validates_uniqueness_of :user_id, :scope => :need_id, :allow_blank => true, :unless => :general_offer?
  validate :only_one_accepted_offer
  
  def general_offer?
    need.nil?
  end
  
  private
  def create_post_for_need
    return true if post_for_need.blank?
    need.posts.create(:text => post_for_need, :user => user)
  end
  
  def only_one_accepted_offer
    if accepted? && need.try(:accepted_offer)
      errors.add(:accepted, "need already has an accepted offer")
    end
  end
  
end