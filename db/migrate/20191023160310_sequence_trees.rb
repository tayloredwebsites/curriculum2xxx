class SequenceTrees < ActiveRecord::Migration[5.1]
  def change
    add_column :trees, :sort_order, :integer, default: 0
  end
end
