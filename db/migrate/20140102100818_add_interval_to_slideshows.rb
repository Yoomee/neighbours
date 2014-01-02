class AddIntervalToSlideshows < ActiveRecord::Migration
  def change
    add_column :slideshows, :interval, :integer, :after => :slug
  end
end
