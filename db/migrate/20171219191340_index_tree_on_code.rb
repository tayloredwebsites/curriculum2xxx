class IndexTreeOnCode < ActiveRecord::Migration[5.1]
  def self.up
    remove_index :trees, name: 'index_trees_on_keys'
    add_index :trees, [:tree_type_id, :version_id, :subject_id, :grade_band_id, :code], name: 'index_trees_on_keys'
  end
  def self.down
    remove_index :trees, name: 'index_trees_on_keys'
    add_index :trees, [:tree_type_id, :version_id, :subject_id, :grade_band_id], name: 'index_trees_on_keys'
  end
end
