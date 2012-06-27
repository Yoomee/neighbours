class Offer < ActiveRecord::Base
  
  belongs_to :need
  belongs_to :user
  validates :text, :need, :user, :presence => true
  validate :only_one_accepted_offer
  
  private
  def only_one_accepted_offer
    if accepted? && need.try(:accepted_offer)
      errors.add(:accepted, "need already has an accepted offer")
    end
  end
  
end