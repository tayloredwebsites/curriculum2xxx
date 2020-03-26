class AddSubjectCodeToDimensions < ActiveRecord::Migration[5.1]
  def change
    add_column :dimensions, :subject_code, :string, default: "", null: false
  end
end
