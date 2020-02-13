class AddVersionIdToTreeTypes < ActiveRecord::Migration[5.1]
  def change
    add_column :tree_types, :version_id, :integer, default: 0, null: false
  end
end
