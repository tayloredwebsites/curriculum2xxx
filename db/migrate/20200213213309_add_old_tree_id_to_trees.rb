class AddOldTreeIdToTrees < ActiveRecord::Migration[5.1]
  def change
    add_column :trees, :old_tree_id, :integer, null: true
  end
end
