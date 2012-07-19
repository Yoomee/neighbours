class CreateNeighbourhoods < ActiveRecord::Migration
  def change
    create_table :neighbourhoods do |t|
      t.string :name
      t.timestamps
    end
    Neighbourhood.create(:name => "Maltby")
  end
end
