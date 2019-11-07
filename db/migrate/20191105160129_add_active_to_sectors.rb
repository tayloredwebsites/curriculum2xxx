class AddActiveToSectors < ActiveRecord::Migration[5.1]
  def change
    add_column :sectors, :active, :boolean, default: true
  end
end
