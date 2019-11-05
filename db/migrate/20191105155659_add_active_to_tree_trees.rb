class AddActiveToTreeTrees < ActiveRecord::Migration[5.1]
  def change
    add_column :tree_trees, :active, :boolean, default: true
  end
end
