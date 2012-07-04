class NeedCategory < ActiveRecord::Base
  include YmCore::Model
  
  has_many :needs,:dependent => :nullify
  validates :name, :description, :presence => true
  
  def self.select_options
    other = NeedCategory.find_by_name("Other")
    order(:name).without(other) << other
  end
end