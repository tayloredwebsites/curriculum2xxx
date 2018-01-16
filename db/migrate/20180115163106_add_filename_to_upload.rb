class AddFilenameToUpload < ActiveRecord::Migration[5.1]
  def change
    add_column :uploads, :filename, :string
  end
end
