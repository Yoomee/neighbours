class AddLatAndLngToPreRegistrations < ActiveRecord::Migration
  def change
    add_column :pre_registrations, :lat, :string
    add_column :pre_registrations, :lng, :string
  end
end
