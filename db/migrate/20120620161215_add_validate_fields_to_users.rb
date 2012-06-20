class AddValidateFieldsToUsers < ActiveRecord::Migration

  def change
    add_column :users, :validate_by, :string
    add_column :users, :validated, :boolean, :default => false
  end

end
