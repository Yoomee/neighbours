class AddCommunityChampionToUser < ActiveRecord::Migration
  def change
    add_column :users, :is_community_champion, :boolean
    add_column :users, :community_champion_id, :integer
    
    add_index :users, :community_champion_id
  end
  
end
