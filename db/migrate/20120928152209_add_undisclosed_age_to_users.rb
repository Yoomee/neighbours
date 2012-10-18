class AddUndisclosedAgeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :undisclosed_age, :boolean, :default => false
  end
end
