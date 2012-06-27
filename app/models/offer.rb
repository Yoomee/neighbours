class Offer < ActiveRecord::Base
  
  belongs_to :need
  belongs_to :user
  
  after_create :create_post_for_need
  
  attr_accessor :post_for_need
  
  validates :need, :user, :presence => true
  validates :post_for_need, :presence => {:on => :create}
  validates_uniqueness_of :user_id, :scope => :need_id, :allow_blank => true
  validate :only_one_accepted_offer
  
  private
  def create_post_for_need
    need.posts.create(:text => post_for_need, :user => user)
  end
  
  def only_one_accepted_offer
    if accepted? && need.try(:accepted_offer)
      errors.add(:accepted, "need already has an accepted offer")
    end
  end
  
end