class GeneralOffer < ActiveRecord::Base

  belongs_to :user
  belongs_to :category, :class_name => "NeedCategory"
  belongs_to :sub_category, :class_name => "NeedCategory"

  validates :category, :description, :presence => true

  def title
    [category,sub_category].compact.map(&:to_s).join(': ')
  end

end