class Group < ActiveRecord::Base

  belongs_to :user
  has_many :posts, :as => :target, :dependent => :destroy
  
  image_accessor :image  
  
  validates :name, :description, :user, :presence => true
  validates_property :format, :of => :image, :in => [:jpeg, :jpg, :png, :gif], :case_sensitive => false, :message => "must be an image"

end