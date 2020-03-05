class AddGradesToGradeBands < ActiveRecord::Migration[5.1]
  def change
    add_column :grade_bands, :min_grade, :integer, default: 999, null: false
    add_column :grade_bands, :max_grade, :integer, default: 999, null: false
  end
end
