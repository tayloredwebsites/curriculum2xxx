class TranslationKeyToNameKey < ActiveRecord::Migration[5.1]
  def change
    rename_column :sectors, :translation_key, :name_key
    rename_column :trees, :translation_key, :name_key
    add_column :sectors, :base_key, :string
    add_column :trees, :base_key, :string
  end
end
