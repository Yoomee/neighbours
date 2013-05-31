class Group < ActiveRecord::Base

  belongs_to :owner, :class_name => 'User', :foreign_key => 'user_id'
  has_many :posts, :as => :target, :dependent => :destroy
  has_and_belongs_to_many :members, :class_name => 'User'
  
  after_create :add_owner_to_members
  
  image_accessor :image
  
  validates :name, :description, :owner, :presence => true
  validates_property :format, :of => :image, :in => [:jpeg, :jpg, :png, :gif], :case_sensitive => false, :message => "must be an image"

  private
  def add_owner_to_members
    self.members << owner
  end

end