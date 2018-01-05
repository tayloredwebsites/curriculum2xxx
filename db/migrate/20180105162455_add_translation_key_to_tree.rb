class AddTranslationKeyToTree < ActiveRecord::Migration[5.1]
  def up
    add_column :trees, :translation_key, :string
    add_index :trees, :translation_key
    add_index :translations, :key
  end
  def down
    #  :translations, column: :translation_key
    remove_index :trees, column: :translation_key
    remove_index :translations, column: :key
    remove_column :trees, :translation_key
  end
end
