class AddActiveToTreeTypes < ActiveRecord::Migration[5.1]
  def change
    add_column :tree_types, :active, :boolean, default: true
  end
end
