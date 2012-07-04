class AddPublishedAtToPages < ActiveRecord::Migration
  
  def self.up
    add_column :pages, :published_at, :datetime, :null => true, :default => nil
    Page.all.each do |page|
      page.update_attribute(:published_at, Time.now) if page.published?
    end
    remove_column :pages, :published
  end
  
  def self.down
    add_column :pages, :published, :boolean, :default => false
    Page.all.each do |page|
      page.update_attribute(:published, true) if page.published_at && page.published_at <= Time.now
    end
    remove_column :pages, :published_at
  end
  
end