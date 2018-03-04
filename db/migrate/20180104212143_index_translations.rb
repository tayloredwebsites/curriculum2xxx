class IndexTranslations < ActiveRecord::Migration[5.1]
  def self.up
    add_index :translations, :value, length: 255

  end
  def self.down
    remove_index :translations, :column => :value
  end
end
