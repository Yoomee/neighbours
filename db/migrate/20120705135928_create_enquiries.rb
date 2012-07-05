class CreateEnquiries < ActiveRecord::Migration
  def change
    create_table :enquiries do |t|
      t.string :form_name
      t.timestamps
    end    
  end
end
