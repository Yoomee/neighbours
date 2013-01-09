class CreatePreRegistrations < ActiveRecord::Migration
  def change
    create_table :pre_registrations do |t|
      t.string :name
      t.string :email
      t.string :postcode

      t.timestamps
    end
  end
end
