class AddActiveToGradeBands < ActiveRecord::Migration[5.1]
  def change
    add_column :grade_bands, :active, :boolean, default: true
  end
end
