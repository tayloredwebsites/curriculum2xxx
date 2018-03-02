class SectorTable < ActiveRecord::Migration[5.1]
  def up

    # # fix problem with tree migration (sqlite?)
    # remove_index :translations, name: 'index_translations_on_translation_key'
    # drop_table 'trees'
    # create_table "trees", force: :cascade do |t|
    #   t.integer "tree_type_id", null: false
    #   t.integer "version_id", null: false
    #   t.integer "subject_id", null: false
    #   t.integer "grade_band_id", null: false
    #   t.string "code"
    #   t.datetime "created_at", null: false
    #   t.datetime "updated_at", null: false
    #   t.string "translation_key"
    #   t.index ["grade_band_id"], name: "index_trees_on_grade_band_id"
    #   t.index ["subject_id"], name: "index_trees_on_subject_id"
    #   t.index ["translation_key"], name: "index_trees_on_translation_key"
    #   t.index ["tree_type_id", "version_id", "subject_id", "grade_band_id", "code"], name: "index_trees_on_keys"
    #   t.index ["tree_type_id"], name: "index_trees_on_tree_type_id"
    #   t.index ["version_id"], name: "index_trees_on_version_id"
    # end

    create_table :sectors do |t|
      t.string :code
      t.string :translation_key
      t.timestamps
    end
    add_index :sectors, :code

    create_join_table :sectors, :trees do |t|
      t.index [:sector_id, :tree_id]
      t.index [:tree_id, :sector_id]
    end
  end
  def down
    drop_table :sectors
    drop_join_table :sectors, :trees
  end
end
