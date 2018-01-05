class IndexTranslations < ActiveRecord::Migration[5.1]
  def self.up
    add_index :translations, [:locale, :key], name: 'index_translations_on_keys'
    add_index :translations, :value

  end
  def self.down
    remove_index :translations, name: 'index_translations_on_keys'
    remove_index :translations, :column => :value
  end
end
