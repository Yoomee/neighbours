class CreateYmSnippetsSnippets < ActiveRecord::Migration
  
  def change
    create_table :ym_snippets_snippets do |t|
      t.string :slug
      t.string :snippet_type
      t.text :text
      t.timestamps
    end
    add_index :ym_snippets_snippets, :slug
  end
  
end
