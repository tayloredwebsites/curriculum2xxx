class CreateSubjectsTreesTable < ActiveRecord::Migration[5.1]
  def up
    create_join_table :trees, :related_trees do |t|
      t.index [:tree_id, :related_tree_id]
    end
  end

  def down
    drop_join_table :trees, :related_trees
  end
end
