class Offer < ActiveRecord::Base
  
  belongs_to :need
  belongs_to :user
  belongs_to :general_offer

  has_one :category, :through => :need
  has_one :need_user, :through => :need, :source => :user

  scope :accepted, where(:accepted => true)
  scope :open_offers, where(:accepted => false)
  
  default_scope where('offers.removed_at IS NULL').joins(:need).where('needs.removed_at IS NULL').readonly(false)

  after_create :create_post_for_need
  
  attr_accessor :post_for_need
  
  validates :user, :presence => true
  validates :post_for_need, :presence => {:on => :create}
  validates_uniqueness_of :user_id, :scope => :need_id, :allow_blank => true
  validate :only_one_accepted_offer

  class << self

    def removed
      unscoped.where('offers.removed_at IS NOT NULL')
    end
  end

  def unscoped_need
    Need.unscoped.find(need_id)
  end
  alias_method :need, :unscoped_need

  def unscoped_general_offer
    GeneralOffer.unscoped.find(general_offer_id) if general_offer_id.present?
  end
  alias_method :general_offer, :unscoped_general_offer
  
  private
  def create_post_for_need
    return true if post_for_need.blank?
    need.posts.create(:text => post_for_need, :user => user)
  end
  
  def only_one_accepted_offer
    if accepted? && need.try(:accepted_offer) && need.accepted_offer != self
      errors.add(:accepted, "need already has an accepted offer")
    end
  end
  
end