class ChangesToUserAddressFields < ActiveRecord::Migration
  def change
    rename_column :users, :address1, :house_number
    add_column    :users, :street_name, :string, :after => :house_number
    remove_column :users, :county
    User.all.each do |user|
      address1_parts = (user.house_number.presence || "123 Bond Street").split(" ")
      user.house_number = address1_parts.shift
      user.street_name = address1_parts.join(" ").presence || "Bond Street"
      user.save
    end
  end
end
