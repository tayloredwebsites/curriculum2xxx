class AddLastVersionIdToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :last_version_id, :integer
  end
end
