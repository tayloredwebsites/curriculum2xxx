class CreateSubjectsTreesTable < ActiveRecord::Migration[5.1]
  def up
    create_join_table :trees, :trees do |t|
      t.index [:tree_id, :tree_id]
    end
  end

  def down
    drop_join_table :trees, :trees
  end
end
