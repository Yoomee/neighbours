class CreateNeedCategories < ActiveRecord::Migration
  def up
    create_table :need_categories do |t|
      t.string :name
      t.text :description
    end
    
    remove_column :needs, :title
    add_column :needs, :category_id, :integer, :after => :user_id
    add_index :needs, :category_id
    
    [
      ["Car and Bike", "Car or bike sharing, breakdown, advice, tool sharing"],
      ["House","Repairs, holiday watch, facilities borrow"],
      ["Shopping","Shopping trips, local shop advice"],
      ["Pet","Pet care, pet walking"],
      ["Garden","Maintenance, design advice, plants, tree problems"],
      ["Child","School walking, school events, babysitting, bullying, mischief"],
      ["Nature","Bird watching, animal spotting, feeding advice, flowers"],
      ["Social","Elderly care, keeping company, making new friends, pubs"],
      ["Cleaning","House or car cleaning, bins, littering, windows"],
      ["Disability Assistance","Wheelchair assistance, elderly, disability parking"],
      ["Swap","Books, films, music, furniture"],
      ["Community","Neighbourhood watch, lobbying, community events ie street parties, housing associations."],
      ["Societies","Clubs and societies, pub teams, local sports groups"],
      ["Health","Health concerns, picking up prescriptions"],
      ["Other","Not covered by above ie, skip sharing, computer help etc"]
    ].each do |name, description|
      NeedCategory.create(:name => name, :description => description)
    end
    
    Need.update_all(:category_id => NeedCategory.find_by_name("Other").id)
  end
  
  def down
    drop_table :need_categories
    add_column :needs, :title, :string
    remove_column :needs, :category_id
  end
end
