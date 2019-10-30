class CreateSequenceOrder < ActiveRecord::Migration[5.1]
  def change
  	add_column :trees, :sequence_order, :integer, default: 0
  end
end
