class CreateOrganisations < ActiveRecord::Migration
  def change
    create_table :organisations do |t|
      t.string :name
      t.integer :admin_id
      t.timestamps
    end

    ["South Yorkshire Housing Association", "Neighbours Can Help", "Maltby Town Council", "Maltby Model Village Community Association", "Maltby Academy"].each do |o|
      Organisation.create(:name => o)
    end 
    
  end
end