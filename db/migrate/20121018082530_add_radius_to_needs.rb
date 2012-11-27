class AddRadiusToNeeds < ActiveRecord::Migration
  def change
    add_column :needs, :radius, :integer, :after => :description, :default => 0
  end
end
