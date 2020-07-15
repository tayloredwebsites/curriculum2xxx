class CreateTreeTypeConfig < ActiveRecord::Migration[5.1]
  def change
    create_table :tree_type_configs do |t|
      t.belongs_to :tree_type
      t.belongs_to :version
      t.string :page_name
      t.string :config_div_name
      t.integer :table_sequence
      t.integer :col_sequence
      t.integer :tree_depth
      t.string :item_lookup
      t.string :resource_code
      t.string :table_partial_name
      t.timestamps
    end

    remove_column :resources, :base_key
  end
end
