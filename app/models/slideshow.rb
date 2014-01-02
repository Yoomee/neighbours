class Slideshow < ActiveRecord::Base
  include YmCms::Slideshow

  validates :interval, :numericality => true

end