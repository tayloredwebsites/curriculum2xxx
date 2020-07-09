class CreateResources < ActiveRecord::Migration[5.1]
  def change
    create_table :resources do |t|
      t.string :base_key, default: "", null: false
      t.string :resource_code, default: "", null: false
      t.timestamps
    end

    create_table :resource_joins do |t|
      t.belongs_to :resource, :null => false, :index => true
      t.references :resourceable, polymorphic: true, index: {name: 'resourceable'}
      t.timestamps
    end

    create_table :user_resources do |t|
      t.belongs_to :resource, :null => false, :index => true
      t.belongs_to :user, :null => false, :index => true
      t.references :user_resourceable, polymorphic: true, index: {name: 'user_resourceable'}
      t.timestamps
    end
  end

end
