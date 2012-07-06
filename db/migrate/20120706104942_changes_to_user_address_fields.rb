class ChangesToUserAddressFields < ActiveRecord::Migration
  
  def self.up    
    rename_column :users, :address1, :house_number
    add_column    :users, :street_name, :string, :after => :house_number
    remove_column :users, :county
    User.reset_column_information
    User.all.each do |user|
      address1_parts = (user.house_number.presence || "123 Bond Street").split(" ")
      user.update_attribute(:house_number, address1_parts.shift)
      user.update_attribute(:street_name, address1_parts.join(" ").presence || "Bond Street")
    end
  end
  
  def self.down
    User.all.each do |user|
      address1_parts = (user.house_number.presence || "123 Bond Street").split(" ")
      user.update_attribute(:house_number, "#{user.house_number} #{user.street_name}")
    end
    add_column :users, :county, :string, :after => :city
    remove_column :users, :street_name
    rename_column :users, :house_number, :address1
  end
  
end
