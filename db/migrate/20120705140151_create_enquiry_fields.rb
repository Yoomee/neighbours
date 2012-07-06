class CreateEnquiryFields < ActiveRecord::Migration
  def change
    create_table :enquiry_fields do |t|
      t.integer :enquiry_id
      t.string :name
      t.text :value
      t.timestamps
    end
  end
end
