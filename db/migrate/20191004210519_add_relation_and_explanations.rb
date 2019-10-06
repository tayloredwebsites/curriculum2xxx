class AddRelationAndExplanations < ActiveRecord::Migration[5.1]
  def self.up
    drop_table :sectors_trees, if_exists: true
    drop_table :related_trees_trees, if_exists: true
    drop_table :subjects_trees, if_exists: true

    create_table :tree_trees do |t|
      t.belongs_to :tree_referencer, class_name: 'Tree', :null => false, :index => true
      t.belongs_to :tree_referencee, class_name: 'Tree', :null => false, :index => true
      t.string :relationship
      t.string :explanation_key
      t.timestamps
    end
    create_table :sector_trees do |t|
      t.belongs_to :sector, :null => false, :index => true
      t.belongs_to :tree, :null => false, :index => true
      t.string :explanation_key
      t.timestamps
    end
  end

  def self.down
    drop_table :tree_trees, if_exists: true
    drop_table :sector_trees, if_exists: true
  end

end
