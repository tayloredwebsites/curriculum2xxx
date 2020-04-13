class AddDimCodesToTreeType < ActiveRecord::Migration[5.1]
  def up
    add_column :tree_types, :dim_codes, :string, default: "bigidea,miscon", null: false
    remove_column :tree_types, :miscon_dim_type
    remove_column :tree_types, :big_ideas_dim_type
    remove_column :tree_types, :ess_q_dim_type
  end

  def down
    remove_column :tree_types, :dim_codes
    add_column :tree_types, :miscon_dim_type, :string, default: "miscon", null: false
    add_column :tree_types, :big_ideas_dim_type, :string, default: "bigidea", null: false
    add_column :tree_types, :ess_q_dim_type, :string, default: "", null: false
  end
end