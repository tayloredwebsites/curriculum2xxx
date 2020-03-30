class UploadsNullGradeBand < ActiveRecord::Migration[5.1]
  def up
    change_column_null(:uploads, :grade_band_id, true)
  end
  def down
    change_column_null(:uploads, :grade_band_id, false)
  end
end
