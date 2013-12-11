class AddContextToMessageThreads < ActiveRecord::Migration
  def change
    add_column :message_threads, :context, :string
  end
end
