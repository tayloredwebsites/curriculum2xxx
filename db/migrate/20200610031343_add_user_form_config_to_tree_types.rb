class AddUserFormConfigToTreeTypes < ActiveRecord::Migration[5.1]
  def up
    add_column :tree_types, :user_form_config, :string, default: "", null: false
    add_column :sectors, :key_phrase, :string, default: "", null: false
  end

  def down
  	remove_column :tree_types, :user_form_config
  	remove_column :sectors, :key_phrase
  end
end