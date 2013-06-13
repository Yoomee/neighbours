class Photo < ActiveRecord::Base

  include YmCore::Model

  belongs_to :group
  belongs_to :user
  
  image_accessor :image

  validates :group, :image, :presence => true

  def to_s
    "#{group} photo"
  end

end