class AddDeltaToPages < ActiveRecord::Migration
  
  def change
    add_column :pages, :delta, :boolean, :before => :created_at, :default => true, :null => false 
  end
  
end