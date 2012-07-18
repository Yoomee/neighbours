class ReplacePublishedAtWithDraftInPages < ActiveRecord::Migration
  
  def self.up
    add_column :pages, :publication_date, :date, :before => :created_at    
    add_column :pages, :draft, :boolean, :default => false, :before => :created_at
    
    Page.reset_column_information
    Page.all.each do |page|
      page.update_attribute(:publication_date, page.published_at)
      page.update_attribute(:draft, page.published_at.nil? ? false : (page.published_at > Time.now))
    end
    
    remove_column :pages, :published_at
  end
  
  def self.down
    add_column :pages, :published_at, :datetime
    
    Page.reset_column_information
    Page.all.each do |page|
      page.update_attribute(:published_at, page.publication_date)
    end
    
    remove_column :pages, :draft
    remove_column :pages, :publication_date
  end
  
end