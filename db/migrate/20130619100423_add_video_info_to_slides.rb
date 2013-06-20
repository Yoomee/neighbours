class AddVideoInfoToSlides < ActiveRecord::Migration
  
  def change
    add_column :slides, :video_url, :string
    add_column :slides, :video_title, :string
    add_column :slides, :video_description, :text
  end
  
end
