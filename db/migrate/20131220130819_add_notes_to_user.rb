class AddNotesToUser < ActiveRecord::Migration
  def change
    add_column :users, :notes, :text, :after => :phone
  end
end
