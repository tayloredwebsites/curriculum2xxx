class SubjectsHaveTranslations < ActiveRecord::Migration[5.1]
  def change
    add_column :subjects, :base_key, :string
  end
end
