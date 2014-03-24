class AddContextToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :context, :string, :after => :target_type
  end
end
