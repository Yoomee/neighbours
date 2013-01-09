class AddAreaToPreRegistrations < ActiveRecord::Migration
  def change
    add_column :pre_registrations, :area, :string
  end
end
