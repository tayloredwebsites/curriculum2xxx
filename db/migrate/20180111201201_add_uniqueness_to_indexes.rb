class AddUniquenessToIndexes < ActiveRecord::Migration[5.1]
  def up
    # remove_index :translations, name: 'index_translations_on_locale_and_key'
    # add_index :translations, ["locale", "key"], name: 'index_translations_on_locale_and_key', unique: true
    # remove_index :trees, name: "index_trees_on_keys"
    # add_index :trees, ["tree_type_id", "version_id", "subject_id", "grade_band_id", "code"], name: "index_trees_on_keys", unique: true
  end
  def down
    # remove_index :translations, name: 'index_translations_on_locale_and_key'
    # add_index :translations, ["locale", "key"], name: 'index_translations_on_locale_and_key'
    # remove_index :trees, name: "index_trees_on_keys"
    # add_index :trees, ["tree_type_id", "version_id", "subject_id", "grade_band_id", "code"], name: "index_trees_on_keys"
  end
end
