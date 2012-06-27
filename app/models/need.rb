class Need < ActiveRecord::Base
  
  belongs_to :user
  has_many :offers
  has_one :accepted_offer, :class_name => 'Offer', :conditions => {:accepted => true}
  
  validates :user, :presence => {:unless => :skip_user_validation?}
  validates :title, :presence => true
  validates :description, :presence => true
  # validate :deadline_is_in_future
  
  boolean_accessor :skip_user_validation
  
  def valid_without_user?
    self.skip_user_validation = true
    is_valid = valid?
    self.skip_user_validation = false
    is_valid
  end
  
  # private
  # def deadline_is_in_future
  #   if new_record? && deadline.present? && (deadline < Date.today)
  #     errors.add(:deadline, "must be in the future")
  #   end
  # end
  
end