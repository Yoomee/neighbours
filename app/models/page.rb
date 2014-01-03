class Page < ActiveRecord::Base
  belongs_to :neighbourhood

  include YmCms::Page
  has_slideshow

  class << self
    
    def view_names
      %w{basic tiled list about_view}
    end

    def get_thumbnail_url(text)
      video_url = extract_video_url_from_text(text)
      video_id = video_url[video_url.rindex("/") + 1..video_url.length]
      response = JSON.parse(open("http://vimeo.com/api/v2/video/#{video_id}.json").read)
      response.first["thumbnail_medium"]
    end

    private

    def extract_video_url_from_text(string)
      substring = "http://player.vimeo.com/video/"
      url_start_index = string.index(substring)
      string[url_start_index..string.index('"', url_start_index)].chop
    end
    
  end
  
end