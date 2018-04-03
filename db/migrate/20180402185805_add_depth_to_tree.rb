class AddDepthToTree < ActiveRecord::Migration[5.1]
  def change
    add_column :trees, :matching_codes, :string, default: '[]'
    add_column :trees, :depth, :integer, default: 0
  end
end
