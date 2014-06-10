class ChangeOrganisationDataForUsers < ActiveRecord::Migration
  def up
    add_column :users, :organisation_id, :integer, :after => :validated

    User.reset_column_information
    User.all.each do |u|
      organisation_name = u.organisation_name      
      if Organisation.all.collect(&:name).include? organisation_name        
        organisation_id = Organisation.find_by_name(organisation_name).id
        u.update_attribute('organisation_id', organisation_id)
      end
    end

    remove_column :users, :organisation_name
  end

  def down
    add_column :users, :organisation_name, :string, :after => :validated

    User.reset_column_information
    User.all.each do |u|
      if u.organisation_id.present?
        organisation_id = u.organisation_id
        organisation_name = Organisation.find(organisation_id).name
        u.update_attribute('organisation_name', organisation_name)
      end
    end

    remove_column :users, :organisation_id
  end
end
