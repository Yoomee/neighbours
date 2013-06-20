class AddSlugToSlideshows < ActiveRecord::Migration
  
  def change
    add_column :slideshows, :slug, :string, :after => :attachable_type
    add_index :slideshows, :slug
  end
  
end