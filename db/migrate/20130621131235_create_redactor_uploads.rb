class CreateRedactorUploads < ActiveRecord::Migration
  
  def change
    create_table :redactor_uploads do |t|
      t.string :file_uid
      t.string :file_type
      t.timestamps
    end
  end
  
end