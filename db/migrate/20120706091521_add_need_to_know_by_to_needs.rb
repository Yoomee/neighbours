class AddNeedToKnowByToNeeds < ActiveRecord::Migration
  def change
    add_column :needs, :need_to_know_by, :string, :default => "anytime", :before => :deadline
  end
end
