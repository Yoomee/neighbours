class SetIsDeletedToFalseOnAllUsers < ActiveRecord::Migration
  def up
    User.update_all(:is_deleted => false)
  end

  def down
  end
end
