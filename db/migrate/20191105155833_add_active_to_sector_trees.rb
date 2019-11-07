class AddActiveToSectorTrees < ActiveRecord::Migration[5.1]
  def change
    add_column :sector_trees, :active, :boolean, default: true
  end
end
