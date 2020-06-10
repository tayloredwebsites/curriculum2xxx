class AddUserFormConfigToTreeTypes < ActiveRecord::Migration[5.1]
  def up
    add_column :tree_types, :user_form_config, :string, default: "", null: false
  end

  def down
  	remove_column :tree_types, :user_form_config
  end
end