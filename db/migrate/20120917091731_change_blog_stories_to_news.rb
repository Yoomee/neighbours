class ChangeBlogStoriesToNews < ActiveRecord::Migration
  def up
    news =  Page.find_by_slug(:news) || Page.create(:slug => 'news', :title => 'News', :view_name => 'list')
    pages = Page.find_by_slug(:blog).try(:children) +  Page.find_by_slug(:stories).try(:children)
    pages.flatten.compact.each do |page|
      page.update_attribute(:parent, news)
    end
  end
  
  def down
  end
end
