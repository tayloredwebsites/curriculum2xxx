class AddActiveToUsers < ActiveRecord::Migration[5.1]
  def up
    add_column :users, :active, :boolean, default: true, null: false
  end

  def down
  	remove_column :users, :active
  end
end
