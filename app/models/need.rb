class Need < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :category, :class_name => "NeedCategory"
  has_many :offers
  has_many :posts, :as => :target
  has_one :accepted_offer, :class_name => 'Offer', :conditions => {:accepted => true}
  
  validates :user, :presence => {:unless => :skip_user_validation?}
  validates :category, :presence => true
  validates :description, :presence => true
  # validate :deadline_is_in_future
  
  boolean_accessor :skip_user_validation
  
  define_index do
    indexes description
    has user_id, category_id, deadline, created_at, updated_at
  end
  
  def valid_without_user?
    self.skip_user_validation = true
    is_valid = valid?
    self.skip_user_validation = false
    is_valid
  end
  
  def title
    category.to_s
  end
  
  # private
  # def deadline_is_in_future
  #   if new_record? && deadline.present? && (deadline < Date.today)
  #     errors.add(:deadline, "must be in the future")
  #   end
  # end
  
end