class TreeTypeUpdates < ActiveRecord::Migration[5.1]
  def change
    add_column :tree_types, :outcome_depth, :integer, default: 0, null: false
    add_column :tree_types, :final_version_id, :integer, default: 0, null: false
    add_column :tree_types, :working_version_id, :integer, default: 0, null: false
    add_column :tree_types, :miscon_dim_type, :string, default: 'miscon', null: false
    add_column :tree_types, :big_ideas_dim_type, :string, default: 'bigidea', null: false
    add_index :tree_types, :code, :unique => true
  end
end
