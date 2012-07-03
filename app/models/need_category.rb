class NeedCategory < ActiveRecord::Base
  has_many :needs
  validates :name, :description, :presence => true
end