class AddUserIdToResourceJoins < ActiveRecord::Migration[5.1]
  def up
  	add_reference :resource_joins, :user

  	drop_table :user_resources
  end

  def down
  	remove_reference :resource_joins, :user

  	create_table :user_resources do |t|
      t.belongs_to :resource, :null => false, :index => true
      t.belongs_to :user, :null => false, :index => true
      t.references :user_resourceable, polymorphic: true, index: {name: 'user_resourceable'}
      t.boolean :active, :null => false, default: true
      t.timestamps
    end
  end
end
