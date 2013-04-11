class NeedCategory < ActiveRecord::Base
  include YmCore::Model
  
  has_many :needs, :foreign_key => :category_id, :dependent => :nullify
  belongs_to :parent, :class_name => "NeedCategory"
  has_many :sub_categories, :class_name => "NeedCategory", :foreign_key => :parent_id
  validates :name, :description, :presence => true
  validate :cannot_be_own_parent
  
  scope :root, where(:parent_id => nil).order(:name)
  
  def self.select_options
    other = NeedCategory.find_by_name("Other")
    root.order(:name).without(other) << other
  end
  
  private
  def cannot_be_own_parent
    if id.present? && id == parent_id
      self.errors.add(:parent, "can't be it's own parent")
    end
  end
  
end