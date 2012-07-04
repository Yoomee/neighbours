class NeedCategory < ActiveRecord::Base
  has_many :needs,:dependent => :nullify
  validates :name, :description, :presence => true
end