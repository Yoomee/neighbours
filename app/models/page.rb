class Page < ActiveRecord::Base
  belongs_to :neighbourhood

  include YmCms::Page
  has_slideshow

  class << self

    def view_names
      %w{basic tiled list about_view}
    end

  end

  def get_thumbnail_url
    video_url = extract_video_url_from_text(text)
    thumbnail_url = 'logo.png'
    if(video_url.presence)
      video_id = video_url[video_url.rindex("/") + 1..video_url.length]
      begin
        response = JSON.parse(open("http://vimeo.com/api/v2/video/#{video_id}.json").read)
        thumbnail_url = response.first["thumbnail_medium"]
      rescue OpenURI::HTTPError => ex
        puts "Video not found"
      end
    end
    thumbnail_url
  end

  private

  def extract_video_url_from_text(string)
    substring = "http://player.vimeo.com/video/"
    url_start_index = string.index(substring)
    if(url_start_index.presence)
      string[url_start_index..string.index('"', url_start_index)].chop
    end
  end

end
