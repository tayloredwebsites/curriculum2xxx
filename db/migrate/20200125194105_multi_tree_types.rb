class MultiTreeTypes < ActiveRecord::Migration[5.1]
  def change
    add_column :tree_types, :hierarchy_codes, :string, default: '', null: false
    add_column :tree_types, :valid_locales, :string, default: 'en', null: false
    add_column :tree_types, :sector_set_code, :string, default: '', null: false
    add_column :tree_types, :sector_set_name_key, :string, default: '', null: false
    add_column :tree_types, :curriculum_title_key, :string, default: '', null: false
    add_column :sectors, :sector_set_code, :string, default: '', null: false
    add_column :uploads, :tree_type_code, :string, default: '', null: false
    add_column :users, :last_tree_type_id, :integer, null: true
    add_column :users, :last_selected_subject_ids, :string, default: '', null: false
  end
end
