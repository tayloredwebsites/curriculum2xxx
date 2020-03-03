class AddGradesToDimensions < ActiveRecord::Migration[5.1]
  def change
    add_column :dimensions, :min_grade, :integer, default: 999, null: false
    add_column :dimensions, :max_grade, :integer, default: 999, null: false
  end
end
