class AddWorkingStatusToTreeTypes < ActiveRecord::Migration[5.1]
  def change
    add_column :tree_types, :working_status, :boolean, default: true
  end
end
