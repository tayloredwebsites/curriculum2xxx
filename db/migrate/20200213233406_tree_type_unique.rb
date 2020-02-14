class TreeTypeUnique < ActiveRecord::Migration[5.1]
  def up
    remove_index :tree_types, :code
    add_index :tree_types, [:code, :version_id], :unique => true
  end

  def down
    remove_index :tree_types, [:code, :version_id]
    add_index :tree_types, :code, :unique => true
  end
end
