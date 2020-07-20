class CreateTreeTypeConfig < ActiveRecord::Migration[5.1]
  def up
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

    add_column :resources, :active, :boolean, default: true, null: false
    add_column :resource_joins, :active, :boolean, default: true, null: false
    add_column :user_resources, :active, :boolean, default: true, null: false
    add_column :lesson_plans, :active, :boolean, default: true, null: false
    add_column :activities, :active, :boolean, default: true, null: false
    add_column :activity_dimensions, :active, :boolean, default: true, null: false
    add_column :lookup_tables_options, :active, :boolean, default: true, null: false
    add_column :user_lesson_plans, :active, :boolean, default: true, null: false

  end

  def down
    drop_table :tree_type_configs

    add_column :resources, :base_key, :string, default: "", null: false

    remove_column :resources, :active
    remove_column :resource_joins, :active
    remove_column :user_resources, :active
    remove_column :lesson_plans, :active
    remove_column :activities, :active
    remove_column :activity_dimensions, :active
    remove_column :lookup_tables_options, :active
    remove_column :user_lesson_plans, :active
  end
end
