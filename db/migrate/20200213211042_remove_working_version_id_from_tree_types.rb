class RemoveWorkingVersionIdFromTreeTypes < ActiveRecord::Migration[5.1]
  def change
    remove_column :tree_types, :working_version_id, :integer
  end
end
