class AddDimDisplayToTreeType < ActiveRecord::Migration[5.1]
  def up
    add_column :tree_types, :dim_display, :string, default: "", null: false
  end

  def down
  	remove_column :tree_types, :dim_display
  end
end
