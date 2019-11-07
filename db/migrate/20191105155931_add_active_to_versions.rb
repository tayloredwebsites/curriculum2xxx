class AddActiveToVersions < ActiveRecord::Migration[5.1]
  def change
    add_column :versions, :active, :boolean, default: true
  end
end
