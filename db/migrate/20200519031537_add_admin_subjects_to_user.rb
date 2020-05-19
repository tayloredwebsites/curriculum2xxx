class AddAdminSubjectsToUser < ActiveRecord::Migration[5.1]
  def up
    add_column :users, :admin_subjects, :string, default: "", null: false
  end

  def down
  	remove_column :users, :admin_subjects
  end
end
