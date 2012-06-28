class CreateSearchQueries < ActiveRecord::Migration
  def change
    create_table :search_queries do |t|
      t.belongs_to :user
      t.text :query
      t.string :model
      t.integer :results_count
      t.timestamps
    end
    add_index :search_queries, :user_id
  end
end
