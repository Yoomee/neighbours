class Page < ActiveRecord::Base
  include YmCms::Page
  
  class << self
    
    def view_names
      %w{basic tiled list about_view}
    end
    
  end
  
end