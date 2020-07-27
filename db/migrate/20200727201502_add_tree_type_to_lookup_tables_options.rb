class AddTreeTypeToLookupTablesOptions < ActiveRecord::Migration[5.1]
  def up
  	add_reference :lookup_tables_options, :tree_type
  	add_reference :lookup_tables_options, :version

  	remove_column :lookup_tables_options, :lookup_translation_key
  end
  def down
  	remove_reference :lookup_tables_options, :tree_type
  	remove_reference :lookup_tables_options, :version

  	add_column :lookup_tables_options, :lookup_translation_key, :string
  end
end
