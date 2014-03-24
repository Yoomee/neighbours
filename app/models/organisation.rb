class Organisation < ActiveRecord::Base
  include YmCore::Model

  belongs_to :admin, :class_name => 'User'
    
  validates :name, :presence => true

  #callbacks

  class << self
    
    

  end
  
  


end