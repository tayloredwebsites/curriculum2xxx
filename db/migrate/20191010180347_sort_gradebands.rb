class SortGradebands < ActiveRecord::Migration[5.1]
  def change
    add_column :grade_bands, :sort_order, :integer, default: 0
  end
end
