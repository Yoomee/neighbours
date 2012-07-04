class AddCommunityChampionToUser < ActiveRecord::Migration
  def change
    add_column :users, :is_community_champion, :boolean
    add_column :users, :community_champion_id, :integer
    add_column :users, :champion_request_at, :datetime
    
    add_index :users, :community_champion_id
    add_index :users, :champion_request_at
  end
  
end
