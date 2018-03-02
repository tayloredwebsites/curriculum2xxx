class MainTables < ActiveRecord::Migration[5.1]
  def change
    create_table :versions do |t|
      t.string :code
      t.timestamps
    end
    create_table :tree_types do |t|
      t.string :code
      t.timestamps
    end
    create_table :locales do |t|
      t.string :code
      t.string :name
      t.timestamps
    end
    create_table :subjects do |t|
      t.integer :tree_type_id, null: false
      t.string :code
      t.timestamps
    end
    add_index :subjects, :tree_type_id
    create_table :grade_bands do |t|
      t.integer :tree_type_id, null: false
      t.string :code
      t.timestamps
    end
    add_index :grade_bands, :tree_type_id
    create_table :trees do |t|
      t.integer :tree_type_id, null: false
      t.integer :version_id, null: false
      t.integer :subject_id, null: false
      t.integer :grade_band_id, null: false
      t.string :code
      t.timestamps
    end
    add_index :trees, :tree_type_id
    add_index :trees, :version_id
    add_index :trees, :subject_id
    add_index :trees, :grade_band_id
    add_index :trees, [:tree_type_id, :version_id, :subject_id, :grade_band_id], name: 'index_trees_on_keys'
    create_table :uploads do |t|
      t.integer :subject_id, null: false
      t.integer :grade_band_id, null: false
      t.integer :locale_id, null: false
      t.integer :status
    end
    add_index :uploads, :subject_id
    add_index :uploads, :grade_band_id
    add_index :uploads, :locale_id
    add_index :uploads, [:subject_id, :grade_band_id, :locale_id], name: 'index_uploads_on_keys'
  end

end
