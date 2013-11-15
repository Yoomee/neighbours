class AddTitleToSlideshows < ActiveRecord::Migration
  def change
    add_column :slideshows, :title, :string
  end
end