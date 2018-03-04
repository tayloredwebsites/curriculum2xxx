class UploadsStatusDetailText < ActiveRecord::Migration[5.1]
  def up
    change_column :uploads, :status_detail, :text
  end
  def down
    # caution here if data larger than 256 char
    change_column :uploads, :status_detail, :string
  end
end
