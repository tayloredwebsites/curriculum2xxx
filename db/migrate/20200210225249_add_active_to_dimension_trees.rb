class AddActiveToDimensionTrees < ActiveRecord::Migration[5.1]
  def change
    add_column :dimension_trees, :active, :boolean, :default => true
  end
end
