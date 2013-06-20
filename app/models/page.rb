class Page < ActiveRecord::Base
  belongs_to :neighbourhood

  include YmCms::Page
  has_slideshow

  class << self
    
    def view_names
      %w{basic tiled list about_view}
    end
    
  end
  
end