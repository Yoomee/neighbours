class AddValidationCodeToUsers < ActiveRecord::Migration
  def up
    add_column :users, :validation_code, :string, :after => "requested_validation_by_credit_card"
    User.reset_column_information
    User.all.each do |user|
      user.send(:generate_validation_code)
      user.save
    end
  end
  
  def down
    remove_column :users, :validation_code
  end
end
