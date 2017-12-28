class AddStatusDetailToUpload < ActiveRecord::Migration[5.1]
  def up
    add_column :uploads, :status_detail, :string
    # change_table :uploads do |t|
    #   t.timestamps
    # end
    add_column :uploads, :created_at, :datetime
    add_column :uploads, :updated_at, :datetime
  end
  def down
    remove_column :uploads, :status_detail, :string
    remove_column :uploads, :created_at
    remove_column :uploads, :updated_at
  end
end
