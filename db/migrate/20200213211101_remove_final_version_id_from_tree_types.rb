class RemoveFinalVersionIdFromTreeTypes < ActiveRecord::Migration[5.1]
  def change
    remove_column :tree_types, :final_version_id, :integer
  end
end
