class NewDimensionsTable < ActiveRecord::Migration[5.1]
  # table to store Big Ideas and Misconceptions and other possible perspectives on the curriculum
  # Note: these normally are associated with a subject, but could be trans-disciplinary
  # ToDo - consider replacing Sectors and SectorTrees with this table.
  def up
    create_table :dimensions do |t|
      t.belongs_to :subject, :null => true, :index => true
      t.string :dim_type
      t.string :dim_code
      t.string :dim_name_key
      t.string :dim_desc_key
      t.integer :dim_order, default: 0
      t.timestamps
    end
    add_index :dimensions, :dim_code
    add_index :dimensions, [:dim_type, :dim_code]

    create_table :dimension_trees do |t|
      t.belongs_to :dimension, :null => false, :index => true
      t.belongs_to :tree, :null => false, :index => true
      t.string :dim_explanation_key
      t.timestamps
    end
  end

  def down
    drop_table :dimensions
    drop_table :dimension_trees
  end

end
