class AddFileFieldsToPosts < ActiveRecord::Migration
  
  def change
    add_column :posts, :file_uid, :string, :after => :video_description
    add_column :posts, :file_name, :string, :after => :file_uid
  end
  
end